import Foundation

public struct Endpoints {
    public enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case PATCH
        case DELETE
    }

    public enum PathParameter: String {
        case roomId
    }

    public struct RouteDefinition {
        public let root: [String]
        public let method: Endpoints.HTTPMethod
        public let path: [String]

        public func fullPath(_ resolvingPathParameters: [PathParameter: String]) -> String {
            var path = (self.root + self.path).joined(separator: "/")
            resolvingPathParameters.forEach { resolvingPathParameter in
                path = path.replacingOccurrences(of: ":" + resolvingPathParameter.key.rawValue,
                                                 with: resolvingPathParameter.value)
            }
            return path
        }
    }

    public struct Action {
        public static let root = ["actions"]
        public static let getAll = RouteDefinition(root: root, method: .GET, path: [])
        public static let getRoomAll = RouteDefinition(root: root, method: .GET, path: [":roomId"])
        public static let getSingle = RouteDefinition(root: root, method: .GET, path: [":actionId"])
        public static let create = RouteDefinition(root: root, method: .POST, path: [])
        public static let delete = RouteDefinition(root: root, method: .DELETE, path: getSingle.path)
    }

    public struct Stroke {
        public static let root = ["strokes"]
        public static let getAll = RouteDefinition(root: root, method: .GET, path: [])
        public static let getRoomAll = RouteDefinition(root: root, method: .GET, path: [":roomId"])
        public static let getSingle = RouteDefinition(root: root, method: .GET, path: [":strokeId"])
        public static let create = RouteDefinition(root: root, method: .POST, path: [])
    }
}
