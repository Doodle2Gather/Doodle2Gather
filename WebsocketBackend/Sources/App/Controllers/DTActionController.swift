import Fluent
import Vapor
import DoodlingAdaptedLibrary

struct DTActionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
//      routes.on(Endpoints.Acroynms.getAll, use: getAllHandler)
    }
}

extension PersistedDTAction {
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db).all()
    }
}
