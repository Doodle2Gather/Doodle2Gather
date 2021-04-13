import Foundation
import Alamofire
import DTSharedLibrary

struct DTApi {

    static let baseURLString = ApiEndpoints.localApi // change to .localApi for local testing

    // MARK: User

    static func sendUserData(id: String, displayName: String, email: String, callback: @escaping () -> Void) {
        let parameters: [String: String] = [
            "id": id,
            "displayName": displayName,
            "email": email
        ]

        AF.request("\(baseURLString)user",
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default)
            .responseJSON { _ in
                callback()
            }
    }

    // MARK: Room

    static func createRoom(name: String, user: String, callback: @escaping (Room) -> Void) {
        let parameters: [String: String] = [
            "name": name,
            "createdBy": user
        ]

        AF.request("\(baseURLString)room",
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default)
            .responseJSON { response in
                guard let data = response.data else {
                    return
                }
                let decodedData = try? JSONDecoder().decode(CreateRoomResponse.self, from: data)

                guard let roomData = decodedData else {
                    return
                }

                guard let roomId = UUID(uuidString: roomData.id) else {
                    return
                }
                let newRoom = Room(roomId: roomId, roomName: roomData.name)
                callback(newRoom)
            }
    }

    static func joinRoom(code: String, user: String, callback: @escaping (Room) -> Void) {

    }

    // TODO: Change room name to the actual one after backend is done
    static var roomCount = 0

    static func getAllRooms(user: String, callback: @escaping ([Room]) -> Void) {
        AF.request("\(baseURLString)user/rooms/\(user)",
                   method: .get)
            .responseJSON { response in

                guard let data = response.data else {
                    return
                }
                let decodedData = try? JSONDecoder().decode([RoomsResponseEntry].self, from: data)
                let decodedRooms = decodedData?.map({ entry -> Room in
                    roomCount += 1
                    print(entry.id)
                    return Room(roomId: UUID(uuidString: entry.room.id)!, roomName: "Room \(roomCount)")
                })
                callback(decodedRooms ?? [])
                // return decodedData as? [DTRoom] ?? []
            }
    }

    static func getParticipants(roomId: UUID, callback: @escaping ([DTParticipant]) -> Void) {

    }

    static func getRoomsDoodles(
        roomId: UUID, callback: @escaping ([DTAdaptedDoodle]) -> Void
    ) {
        AF.request("\(baseURLString)room/doodles/\(roomId.uuidString)",
                   method: .get)
            .responseJSON { response in

                guard let data = response.data else {
                    return
                }
                let decodedData = try? JSONDecoder().decode([DoodleResponseEntry].self, from: data)
                let decodedDoodles = decodedData?.map({ entry -> DTAdaptedDoodle in
                    DTAdaptedDoodle(roomId: roomId, doodleId: UUID(uuidString: entry.id)!, strokes: [])
                })
                callback(decodedDoodles ?? [])
            }
    }

    // MARK: Strokes

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

    // MARK: Actions

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
