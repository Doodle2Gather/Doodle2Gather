import Fluent
import Vapor
import DoodlingAdaptedLibrary

struct DTActionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Action.getAll, use: getAllHandler)
    }
    
    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedAction]> {
        PersistedDTAction.getAll(on: req.db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedAction.init)
            }
    }
}

// MARK: - Queries

extension PersistedDTAction {
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db).all()
    }
}
