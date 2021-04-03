import Fluent
import Vapor
import DoodlingAdaptedLibrary

struct DTStrokeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Stroke.getAll, use: getAllHandler)
    }
    
    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedStroke]> {
        PersistedDTStroke.getAll(on: req.db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedStroke.init)
            }
    }
}

// MARK: - Queries

extension PersistedDTStroke {
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTStroke]> {
        PersistedDTStroke.query(on: db).all()
    }
}
