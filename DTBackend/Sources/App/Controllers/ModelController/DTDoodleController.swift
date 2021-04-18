import Fluent
import Vapor
import DTSharedLibrary

struct DTDoodleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Doodle.create, use: createHandler)
        routes.on(Endpoints.Doodle.getDoodleFromDooleId, use: getSingleHandler)
        routes.on(Endpoints.Doodle.getAllStrokes, use: getAllStrokesHandler)
        routes.on(Endpoints.Doodle.delete, use: deleteHandler)
    }

    func createHandler(req: Request) throws -> EventLoopFuture<DTAdaptedDoodle> {
        let create = try req.content.decode(DTAdaptedDoodle.CreateRequest.self)
        let newDoodle = create.makePersistedDoodle()

        return newDoodle.save(on: req.db)
            .flatMap { PersistedDTDoodle.getSingleById(newDoodle.id, on: req.db) }
            .flatMapThrowing(DTAdaptedDoodle.init)
    }

    func getSingleHandler(req: Request) throws -> EventLoopFuture<DTAdaptedDoodle> {
        let doodleId = try req.requireUUID(parameterName: "doodleId")

        return PersistedDTDoodle.getSingleById(doodleId, on: req.db)
            .flatMapThrowing(DTAdaptedDoodle.init)
    }

    func getAllStrokesHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedStroke]> {
        let doodleId = try req.requireUUID(parameterName: "doodleId")

        return PersistedDTDoodle.getAllStrokes(doodleId, on: req.db)
            .flatMapThrowing { strokes in
                strokes.map(DTAdaptedStroke.init)
            }
    }

    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let doodleId = try req.requireUUID(parameterName: "doodleId")

        return PersistedDTDoodle.getSingleById(doodleId, on: req.db)
            .flatMap { doodle in
                doodle.delete(on: req.db)
            }
            .transform(to: .noContent)
    }

}

// MARK: - Queries

// contains queries that return adapted model
extension PersistedDTDoodle {

    static func createDoodle(_ request: DTAdaptedDoodle.CreateRequest,
                             on db: Database) -> EventLoopFuture<DTAdaptedDoodle> {
        let newDoodle = request.makePersistedDoodle()
        return newDoodle.save(on: db)
            .flatMap { PersistedDTDoodle.getSingleById(newDoodle.id, on: db) }
            .flatMapThrowing(DTAdaptedDoodle.init)
    }

    static func removeDoodle(_ doodleId: UUID, on db: Database) -> EventLoopFuture<Void> {
        getSingleById(doodleId, on: db)
            .flatMap { $0.delete(on: db) }
    }
}

// contains queries that return persisted model
extension PersistedDTDoodle {

    static func getSingleById(_ id: PersistedDTDoodle.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTDoodle> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTDoodle"))
      }
      return PersistedDTDoodle.query(on: db)
        .filter(\.$id == id)
        .with(\.$actions)
        .with(\.$strokes)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTDoodle", id: id.uuidString))
    }

    static func getAllActions(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        getSingleById(id, on: db)
            .map { $0.actions }
    }

    static func getAllStrokes(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTStroke]> {
        getSingleById(id, on: db)
            .map { $0.strokes }
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        PersistedDTDoodle.query(on: db)
            .with(\.$actions)
            .with(\.$strokes)
            .all()
    }
}
