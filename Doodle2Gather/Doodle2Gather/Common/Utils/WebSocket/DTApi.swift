import Foundation
import DoodlingAdaptedLibrary

struct DTApi {

    static let baseURLString = ApiEndpoints.Api // change to .localApi for local testing

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
        pathParameters: [Endpoints.RouteDefinition.PathParameter: String] = [:],
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
        pathParameters: [Endpoints.RouteDefinition.PathParameter: String] = [:],
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
        print("\(Date()): \(error)")
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
