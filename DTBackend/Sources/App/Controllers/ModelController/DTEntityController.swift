import Fluent
import Vapor
import DTSharedLibrary

struct DTEntityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Stroke.getAll, use: getAllHandler)
        routes.on(Endpoints.Stroke.getRoomAll, use: getDoodleAllHandler)
    }

    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedStroke]> {
        PersistedDTEntity.getAll(on: req.db)
            .flatMapThrowing { entities in
                entities.map(DTAdaptedStroke.init)
            }
    }

    func getDoodleAllHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedStroke]> {
        let doodleId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTDoodle.getAllStrokes(doodleId, on: req.db)
            .flatMapThrowing { entities in
                entities.map(DTAdaptedStroke.init)
            }
    }
}

// MARK: - Queries

extension PersistedDTEntity {

    // swiftlint:disable first_where
    static func getSingle(_ entity: Data, on db: Database) -> EventLoopFuture<PersistedDTEntity> {
        PersistedDTEntity.query(on: db)
            .filter(\.$entityData == entity)
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTEntity"))
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTEntity]> {
        PersistedDTEntity.query(on: db).all()
    }
}
