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
        let newRoom = create.makePersistedRoom()

        let user = PersistedDTUser.getSingleById(create.ownerId, on: req.db)
        let room = newRoom.save(on: req.db)
            .flatMap { PersistedDTRoom.getSingleById(newRoom.id, on: req.db) }

        return room.and(user)
            .flatMap { (room: PersistedDTRoom, user: PersistedDTUser) in
                let attachRoom = user.$accessibleRooms.attach(room, on: req.db)
                let newDoodle = PersistedDTDoodle(room: room)
                let defaultDoodle = newDoodle.save(on: req.db)
                return attachRoom.and(defaultDoodle)
                    .flatMap { _ in PersistedDTRoom.getSingleById(room.id, on: req.db) }
                    .map { r in DTAdaptedRoom(room: r) }
            }
    }

    func getSingleHandler(req: Request) throws -> EventLoopFuture<DTAdaptedDoodle> {

    }

    func getAllStrokesHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedStroke]> {

    }

    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {

    }

}

// MARK: - Queries

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
