import Fluent
import Vapor
import DTSharedLibrary

private struct DTRoomCreationRequest: Codable {
    var name: String
    var createdBy: String
}

private struct DTRoomJoinRequest: Codable {
    var userId: String
    // Join with either the invite code or room uuid
    var inviteCode: String?
    var roomId: String?
}

struct DTRoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Room.createRoom, use: createRoomHandler)
        routes.on(Endpoints.Room.getRoomFromRoomId, use: getRoomFromRoomIdHandler)
        routes.on(Endpoints.Room.getRoomFromInvite, use: getRoomFromInviteHandler)
        routes.on(Endpoints.Room.joinRoomFromInvite, use: joinRoomFromInviteHandler)
    }

    func createRoomHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
        let newDTRoomRequest = try req.content.decode(DTRoomCreationRequest.self)
        let newDTRoom = PersistedDTRoom(name: newDTRoomRequest.name,
                                        createdBy: newDTRoomRequest.createdBy)
        let user = PersistedDTUser.query(on: req.db)
            .filter(\.$id == newDTRoomRequest.createdBy)
            .first()
            .unwrap(or: Abort(.notFound))
        
        let save = newDTRoom.save(on: req.db).map {
            newDTRoom
        }
        return save.and(user).flatMap { room, user in
            user
                .$accessibleRooms
                .attach(room, on: req.db)
                .transform(to: room)
        }
    }
    
    func getRoomFromInviteHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
        guard let code = req.parameters.get("code") else {
            throw Abort(.badRequest)
        }
        return PersistedDTRoom.query(on: req.db)
            .filter(\.$inviteCode == code)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func getRoomFromRoomIdHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
        guard let roomId = req.parameters.get("roomId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return PersistedDTRoom.query(on: req.db)
            .filter(\.$id == roomId)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func joinRoomFromInviteHandler(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let joinRequest = try req.content.decode(DTRoomJoinRequest.self)
        
        if let inviteCode = joinRequest.inviteCode {
            let room = PersistedDTRoom.query(on: req.db)
                .filter(\.$inviteCode == inviteCode)
                .first()
                .unwrap(or: Abort(.notFound))
            let user = PersistedDTUser.query(on: req.db)
                .filter(\.$id == joinRequest.userId)
                .first()
                .unwrap(or: Abort(.notFound))
            return user.and(room).flatMap { user, room in
                user
                    .$accessibleRooms
                    .attach(room, on: req.db)
                    .transform(to: .created)
            }
        }
        
        if let roomId = joinRequest.roomId {
            guard let roomUuid = UUID(uuidString: roomId) else {
                throw Abort(.badRequest)
            }
            let room = PersistedDTRoom.query(on: req.db)
                .filter(\.$id == roomUuid)
                .first()
                .unwrap(or: Abort(.notFound))
            let user = PersistedDTUser.query(on: req.db)
                .filter(\.$id == joinRequest.userId)
                .first()
                .unwrap(or: Abort(.notFound))
            return user.and(room).flatMap { user, room in
                user
                    .$accessibleRooms
                    .attach(room, on: req.db)
                    .transform(to: .created)
            }
        }
        throw Abort(.badRequest)
    }

    // TODO: - Change return types to Adapted Models instead

//    func getSingleHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
//
//    }
//    
//    func getAllHandler(req: Request) throws -> EventLoopFuture<[PersistedDTRoom]> {
//
//    }
//    
//    func createHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
//
//    }
//    
//    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
//
//    }
//    
//    func addDoodleHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
//
//    }
}

// MARK: - Queries

extension PersistedDTRoom {

    static func getSingleByID(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
      }
      return PersistedDTRoom.query(on: db)
        .filter(\.$id == id)
        .with(\.$doodles)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", id: id.uuidString))
    }

    static func getAllDoodles(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        getSingleByID(id, on: db)
            .flatMapThrowing { $0.doodles }
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        PersistedDTRoom.query(on: db)
            .with(\.$doodles)
            .all()
    }
}
