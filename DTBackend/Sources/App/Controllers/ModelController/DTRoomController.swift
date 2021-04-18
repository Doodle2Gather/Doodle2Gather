import Fluent
import Vapor
import DTSharedLibrary

struct DTRoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Room.create, use: createHandler)
        routes.on(Endpoints.Room.getRoomFromRoomId, use: getSingleHandler)
        routes.on(Endpoints.Room.getRoomFromInvite, use: getSingleFromInviteHandler)
        routes.on(Endpoints.Room.joinRoomFromInvite, use: joinRoomFromInviteHandler)
        routes.on(Endpoints.Room.getAllDoodlesFromRoom, use: getAllDoodlesHandler)
        routes.on(Endpoints.Room.delete, use: deleteHandler)
        routes.on(Endpoints.Room.getRoomPermissionsFromRoomId, use: getRoomPermissionsHandler)
    }

    func createHandler(req: Request) throws -> EventLoopFuture<DTAdaptedRoom> {
        let create = try req.content.decode(DTAdaptedRoom.CreateRequest.self)
        let newRoom = create.makePersistedRoom()

        let user = PersistedDTUser.getSingleById(create.ownerId, on: req.db)
        let room = newRoom.save(on: req.db)
            .flatMap { PersistedDTRoom.getSingleById(newRoom.id, on: req.db) }

        return room.and(user)
            .flatMap { (room: PersistedDTRoom, user: PersistedDTUser) in
                let attachRoom = user.$accessibleRooms.attach(room, on: req.db) {
                    $0.setDefaultPermissions()
                    $0.isOwner = true
                }
                let newDoodle = PersistedDTDoodle(room: room)
                let defaultDoodle = newDoodle.save(on: req.db)
                return attachRoom.and(defaultDoodle)
                    .flatMap { _ in PersistedDTRoom.getSingleById(room.id, on: req.db) }
                    .map { r in DTAdaptedRoom(room: r) }
            }
    }

    func getSingleHandler(req: Request) throws -> EventLoopFuture<DTAdaptedRoom> {
        let roomId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTRoom.getSingleById(roomId, on: req.db)
            .flatMapThrowing(DTAdaptedRoom.init)
    }

    func getSingleFromInviteHandler(req: Request) throws -> EventLoopFuture<DTAdaptedRoom> {
        guard let code = req.parameters.get("code") else {
            throw Abort(.badRequest)
        }
        return PersistedDTRoom.getSingleByCode(code, on: req.db)
            .flatMapThrowing(DTAdaptedRoom.init)
    }

    func getAllDoodlesHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedDoodle]> {
        let roomId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTRoom.getAllDoodles(roomId, on: req.db)
            .flatMapThrowing { doodles in
                doodles.map(DTAdaptedDoodle.init)
            }
    }

    func getRoomPermissionsHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedUserAccesses]> {
        let roomId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTRoom.getRoomDTUserAccesses(roomId, on: req.db)
            .flatMapThrowing { userAccesses in
                userAccesses.map(DTAdaptedUserAccesses.init)
            }
    }

    func joinRoomFromInviteHandler(req: Request) throws -> EventLoopFuture<DTAdaptedRoom> {
        let joinRequest = try req.content.decode(DTJoinRoomViaInviteMessage.self)

        /* join room via invitation code */

        if let inviteCode = joinRequest.inviteCode {
            let room = PersistedDTRoom.getSingleByCode(inviteCode, on: req.db)
            let user = PersistedDTUser.getSingleById(joinRequest.userId, on: req.db)
            return user.and(room).flatMap { user, room in
                user.$accessibleRooms.attach(room, on: req.db) {
                    $0.setDefaultPermissions()
                }
            }
            .flatMap { PersistedDTRoom.getSingleByCode(inviteCode, on: req.db) }
            .flatMapThrowing(DTAdaptedRoom.init)
        }

        /* join room via room id */

        if let roomId = joinRequest.roomId {
            let room = PersistedDTRoom.getSingleById(roomId, on: req.db)
            let user = PersistedDTUser.getSingleById(joinRequest.userId, on: req.db)
            return user.and(room).flatMap { user, room in
                user.$accessibleRooms.attach(room, on: req.db) {
                    $0.setDefaultPermissions()
                    $0.isOwner = true
                }
            }
            .flatMap { PersistedDTRoom.getSingleById(roomId, on: req.db) }
            .flatMapThrowing(DTAdaptedRoom.init)
        }

        throw Abort(.badRequest)
    }

    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let roomId = try req.requireUUID(parameterName: "roomId")

        return PersistedDTRoom.getSingleById(roomId, on: req.db)
            .flatMap { room in
                room.delete(on: req.db)
            }
            .transform(to: .noContent)
    }

}

// MARK: - Queries

extension PersistedDTRoom {

    static func getSingleById(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
        guard let id = id else {
            return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
        }
        return PersistedDTRoom.query(on: db)
            .filter(\.$id == id)
            .with(\.$doodles, { $0.with(\.$strokes) })
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", id: id.uuidString))
    }

    static func getSingleByCode(_ code: String, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
        PersistedDTRoom.query(on: db)
            .filter(\.$inviteCode == code)
            .with(\.$doodles, { $0.with(\.$strokes) })
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", code: code))
    }

    static func getAllDoodles(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        getSingleById(id, on: db)
            .flatMapThrowing { $0.getChildren() }
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        PersistedDTRoom.query(on: db)
            .with(\.$doodles)
            .all()
    }

    static func getRoomDTUserAccesses(_ id: PersistedDTRoom.IDValue?,
                                      on db: Database) -> EventLoopFuture<[PersistedDTUserAccesses]> {
        guard let id = id else {
            return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
        }
        return PersistedDTUserAccesses
            .query(on: db)
            .with(\.$room)
            .with(\.$user, { $0.with(\.$accessibleRooms, { $0.with(\.$doodles, { $0.with(\.$strokes) }) }) })
            .filter(\.$room.$id == id)
            .all()
    }

    static func getRoomPermissions(roomId: UUID, on db: Database) -> EventLoopFuture<[DTAdaptedUserAccesses]> {
        PersistedDTRoom.getRoomDTUserAccesses(roomId, on: db)
            .flatMapThrowing { userAccesses in
                userAccesses.map(DTAdaptedUserAccesses.init)
            }
    }
}
