import Fluent
import Vapor
import DTSharedLibrary

struct DTStrokeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Stroke.getAll, use: getAllHandler)
        routes.on(Endpoints.Stroke.getRoomAll, use: getDoodleAllHandler)
    }

    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedStroke]> {
        PersistedDTStroke.getAll(on: req.db)
            .flatMapThrowing { strokes in
                strokes.map(DTAdaptedStroke.init)
            }
    }

    func getDoodleAllHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedStroke]> {
        let doodleId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTDoodle.getAllStrokes(doodleId, on: req.db)
            .flatMapThrowing { strokes in
                strokes.map(DTAdaptedStroke.init)
            }
    }
}

// MARK: - Queries

extension PersistedDTStroke {

    // swiftlint:disable first_where
    static func getSingle(_ stroke: Data, on db: Database) -> EventLoopFuture<PersistedDTStroke> {
        PersistedDTStroke.query(on: db)
            .filter(\.$strokeData == stroke)
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTStroke"))
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTStroke]> {
        PersistedDTStroke.query(on: db).all()
    }
}
