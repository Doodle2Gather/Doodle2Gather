import Foundation
import Alamofire
import DTSharedLibrary

struct DTApi {

    static let baseURLString = ApiEndpoints.Api // change to .localApi for local testing

    // MARK: - User

    static func sendUserData(
        id: String, displayName: String, email: String,
        completion: @escaping (DTApiResult<[DTAdaptedUser]>) -> Void
    ) {
        let newUserData = DTAdaptedUser.CreateRequest(id: id, displayName: displayName, email: email)
        perform(Endpoints.User.createUserInfo,
                send: newUserData,
                completion: completion)
    }

    // MARK: - Room

    static func createRoom(
        _ room: DTAdaptedRoom.CreateRequest,
        completion: ((DTApiResult<DTAdaptedRoom>) -> Void)? = nil
    ) {
        perform(Endpoints.Room.create, send: room, completion: completion)
    }

    static func getRoomFromId(
        id: UUID,
        completion: @escaping (DTApiResult<DTAdaptedRoom>) -> Void
    ) {
        perform(Endpoints.Room.getRoomFromRoomId,
                pathParameters: [.roomId: id.uuidString],
                completion: completion)
    }

    static func getRoomFromInvite(
        id: UUID,
        completion: @escaping (DTApiResult<DTAdaptedRoom>) -> Void
    ) {
        perform(Endpoints.Room.getRoomFromInvite,
                pathParameters: [.roomId: id.uuidString],
                completion: completion)
    }

    static func getAllRooms(user: String, callback: @escaping ([Room]) -> Void) {
        AF.request("\(baseURLString)/user/rooms/\(user)",
                   method: .get)
            .responseJSON { response in

                guard let data = response.data else {
                    return
                }
                let decodedData = try? JSONDecoder().decode([RoomsResponseEntry].self, from: data)
                let decodedRooms = decodedData?.map({ entry -> Room in
                    Room(roomId: UUID(uuidString: entry.room.id) ?? UUID(),
                         roomName: entry.room.name,
                         inviteCode: entry.room.inviteCode)
                })
                callback(decodedRooms ?? [])
                // return decodedData as? [DTRoom] ?? []
            }
    }

    static func getParticipants(roomId: UUID, callback: @escaping ([DTParticipant]) -> Void) {

    }

    static func joinRoomFromInvite(
        joinRoomRequest: DTJoinRoomMessage,
        completion: @escaping (DTApiResult<DTAdaptedRoom>) -> Void
    ) {
        perform(Endpoints.Room.joinRoomFromInvite,
                send: joinRoomRequest,
                completion: completion)
    }

    static func getRoomsDoodles(
        roomId: UUID,
        completion: @escaping (DTApiResult<[DTAdaptedDoodle]>) -> Void
    ) {
        perform(Endpoints.Room.getAllDoodlesFromRoom,
                pathParameters: [.roomId: roomId.uuidString],
                completion: completion)
    }

    static func deleteRoom(
        roomId: UUID,
        completion: ((DTApiResult<EmptyResponse>) -> Void)? = nil
    ) {
        perform(Endpoints.Room.delete,
                pathParameters: [.roomId: roomId.uuidString],
                completion: completion)
    }

    // MARK: - Doodles

    static func createDoodle(
        _ doodle: DTAdaptedDoodle.CreateRequest,
        completion: ((DTApiResult<DTAdaptedDoodle>) -> Void)? = nil
    ) {
        perform(Endpoints.Doodle.create, send: doodle, completion: completion)
    }

    static func getDoodleFromId(
        id: UUID,
        completion: @escaping (DTApiResult<DTAdaptedDoodle>) -> Void
    ) {
        perform(Endpoints.Doodle.getDoodleFromDooleId,
                pathParameters: [.doodleId: id.uuidString],
                completion: completion)
    }

    static func getDoodleStrokes(
        doodleId: UUID,
        completion: @escaping (DTApiResult<[DTAdaptedStroke]>) -> Void
    ) {
        perform(Endpoints.Doodle.getAllStrokes,
                pathParameters: [.doodleId: doodleId.uuidString],
                completion: completion)
    }

    static func deleteDoodle(
        doodleId: UUID,
        completion: ((DTApiResult<EmptyResponse>) -> Void)? = nil
    ) {
        perform(Endpoints.Doodle.delete,
                pathParameters: [.doodleId: doodleId.uuidString],
                completion: completion)
    }

    // MARK: - Strokes

    static func getAllStrokes(
        completion: @escaping (DTApiResult<[DTAdaptedStroke]>) -> Void
    ) {
        perform(Endpoints.Stroke.getAll, completion: completion)
    }

    static func getStrokes(
        roomId: UUID,
        completion: @escaping (DTApiResult<[DTAdaptedStroke]>) -> Void
    ) {
        perform(Endpoints.Stroke.getRoomAll,
                pathParameters: [.roomId: roomId.uuidString],
                completion: completion)
    }

    // MARK: - Actions

    static func getAllActions(
        completion: @escaping (DTApiResult<[DTAdaptedAction]>) -> Void
    ) {
        perform(Endpoints.Action.getAll, completion: completion)
    }

    static func getActions(
        roomId: UUID,
        completion: @escaping (DTApiResult<[DTAdaptedAction]>) -> Void
    ) {
        perform(Endpoints.Action.getRoomAll,
                pathParameters: [.roomId: roomId.uuidString],
                completion: completion)
    }
}

// MARK: - API helper methods

extension DTApi {

    typealias EmptyInputModel = String

    // Overload when no `InputModel` is required.
    static func perform<OutputModel>(
        _ routeDefinition: Endpoints.RouteDefinition,
        pathParameters: [Endpoints.PathParameter: String] = [:],
        completion: ((DTApiResult<OutputModel>) -> Void)? = nil
    ) where OutputModel: Codable {
        perform(
            routeDefinition,
            pathParameters: pathParameters,
            send: nil as EmptyInputModel?,
            completion: completion
        )
    }

    static func perform<InputModel, OutputModel>(
        _ routeDefinition: Endpoints.RouteDefinition,
        pathParameters: [Endpoints.PathParameter: String] = [:],
        send: InputModel? = nil,
        completion: ((DTApiResult<OutputModel>) -> Void)? = nil
    ) where InputModel: Codable, OutputModel: Codable {
        do {

            guard var resourceURL = URL(string: baseURLString) else {
                fatalError("No resource URL provided.")
            }
            resourceURL = resourceURL.appendingPathComponent(routeDefinition.fullPath(pathParameters))

            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = routeDefinition.method.rawValue

            if let resourceToSend = send {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(resourceToSend)
            }

            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                    let jsonData = data
                else {
                    if let error = error {
                        handleError(error, completion: completion)
                    } else {
                        handleError(
                            APIError(localizedDescription: "Something went wrong: \(resourceURL)"),
                            completion: completion)
                    }
                    return
                }
                let resource = try? JSONDecoder().decode(OutputModel.self, from: jsonData)
                completion?(.success(resource))
            }
            dataTask.resume()
        } catch {
            handleError(error, completion: completion)
        }
    }

    private static func handleError<OutputModel>(
        _ error: Error,
        completion: ((DTApiResult<OutputModel>) -> Void)? = nil
    ) where OutputModel: Codable {
        DTLogger.error("\(Date()): \(error)")
        completion?(.failure(error))
    }

    struct APIError: Error {
        let localizedDescription: String?
    }
}

enum DTApiResult<ResourceType> {
    case success(ResourceType?)
    case failure(Error)
}
struct EmptyResponse: Codable {}

// MARK: - API Request helper struct (to be removed)

struct RoomsResponseEntry: Codable {
    let id: String
    let user: RoomsResponseUserEntry
    let room: RoomsResponseRoomEntry
}

struct RoomsResponseUserEntry: Codable {
    let id: String
}

struct RoomsResponseRoomEntry: Codable {
    let id: String
    let inviteCode: String
    let name: String
    let createdBy: userEntry
}

struct DoodleResponseEntry: Codable {
    let id: String
    let room: RoomsResponseRoomEntry
}

struct CreateRoomResponse: Codable {
    let id: String
    let inviteCode: String
    let name: String
    let createdBy: userEntry
}

struct userEntry: Codable {
    let id: String
}
