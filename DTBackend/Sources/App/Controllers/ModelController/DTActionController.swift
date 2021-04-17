import Fluent
import Vapor
import DTSharedLibrary

struct DTActionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Action.getAll, use: getAllHandler)
        routes.on(Endpoints.Action.getRoomAll, use: getDoodleAllHandler)
    }

    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedAction]> {
        PersistedDTAction.getAll(on: req.db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedAction.init)
            }
    }

    func getDoodleAllHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedAction]> {
        let doodleId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTDoodle.getAllActions(doodleId, on: req.db)
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

    static func getLatest(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db)
            .sort(\.$createdAt, .descending)
            .range(..<5)
            .all()
    }
}
