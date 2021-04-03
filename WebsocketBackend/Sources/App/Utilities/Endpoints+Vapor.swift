import Vapor
import DoodlingAdaptedLibrary

extension Endpoints.RouteDefinition {
    var httpMethod: Vapor.HTTPMethod { .init(rawValue: method.rawValue) }
    var pathComponents: [Vapor.PathComponent] { path.toPathComponents }
    var rootComponents: [Vapor.PathComponent] { root.toPathComponents }
}

extension Array where Element == String {
  var toPathComponents: [PathComponent] { self.map(PathComponent.init) }
}

extension RoutesBuilder {
  @discardableResult
  public func on<Response>(
    _ routeDefinition: Endpoints.RouteDefinition,
    use closure: @escaping (Request) throws -> Response
  ) -> Route where Response: ResponseEncodable {
    self.on(routeDefinition.httpMethod, routeDefinition.pathComponents, use: closure)
  }
}
