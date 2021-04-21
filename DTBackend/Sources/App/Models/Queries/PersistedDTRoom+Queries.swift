import Fluent
import Vapor
import DTSharedLibrary

/// Contains queries on `PersistedDTRoom` that return adapted models
extension PersistedDTRoom {

    /// Creates a new room and returns the `DTAdaptedRoom` for the new room
    static func createRoom(_ createRequest: DTAdaptedRoom.CreateRequest,
                           on db: Database) -> EventLoopFuture<DTAdaptedRoom> {

        let newRoom = createRequest.makePersistedRoom()

        let user = PersistedDTUser.getSingleById(createRequest.ownerId, on: db)
        let room = newRoom.save(on: db)
            .flatMap { PersistedDTRoom.getSingleById(newRoom.id, on: db) }

        return room.and(user)
            .flatMap { (room: PersistedDTRoom, user: PersistedDTUser) in
                let attachRoom = user.$accessibleRooms.attach(room, on: db) {
                    $0.setDefaultPermissions()
                    $0.isOwner = true
                }
                let newDoodle = PersistedDTDoodle(room: room)
                let defaultDoodle = newDoodle.save(on: db)
                return attachRoom.and(defaultDoodle)
                    .flatMap { _ in PersistedDTRoom.getSingleById(room.id, on: db) }
                    .map { r in DTAdaptedRoom(room: r) }
            }
    }

    /// Adds a room to the accessible rooms by a user via invite code
    static func joinRoomViaInvite(_ joinRequest: DTJoinRoomViaInviteMessage,
                                  on db: Database) -> EventLoopFuture<DTAdaptedRoom> {

        if let inviteCode = joinRequest.inviteCode {
            let room = PersistedDTRoom.getSingleByCode(inviteCode, on: db)
            let user = PersistedDTUser.getSingleById(joinRequest.userId, on: db)
            return user.and(room).flatMap { user, room in
                user.$accessibleRooms.attach(room, on: db) {
                    $0.setDefaultPermissions()
                }
            }
            .flatMap { PersistedDTRoom.getSingleByCode(inviteCode, on: db) }
            .flatMapThrowing(DTAdaptedRoom.init)
        } else {
            guard let roomId = joinRequest.roomId else {
                return db.eventLoop
                    .makeFailedFuture(
                        DTError.modelNotFound(type: "joinRequest.roomId or joinRequest.inviteCode")
                    )
            }
            let room = PersistedDTRoom.getSingleById(roomId, on: db)
            let user = PersistedDTUser.getSingleById(joinRequest.userId, on: db)
            return user.and(room).flatMap { user, room in
                user.$accessibleRooms.attach(room, on: db) {
                    $0.setDefaultPermissions()
                    $0.isOwner = true
                }
            }
            .flatMap { PersistedDTRoom.getSingleById(roomId, on: db) }
            .flatMapThrowing(DTAdaptedRoom.init)
        }
    }

    /// Get all users and their permission with regard to a room 
    static func getRoomPermissions(roomId: UUID, on db: Database) -> EventLoopFuture<[DTAdaptedUserAccesses]> {
        PersistedDTRoom.getRoomDTUserAccesses(roomId, on: db)
            .flatMapThrowing { userAccesses in
                userAccesses.map(DTAdaptedUserAccesses.init)
            }
    }
}

/// Contains queries on `PersistedDTRoom` that return persisted models
extension PersistedDTRoom {

    /// Gets a room by its room id
    static func getSingleById(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
        guard let id = id else {
            return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
        }
        return PersistedDTRoom.query(on: db)
            .filter(\.$id == id)
            .with(\.$doodles, { $0.with(\.$entities) })
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", id: id.uuidString))
    }

    /// Gets a room by its invite code
    static func getSingleByCode(_ code: String, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
        PersistedDTRoom.query(on: db)
            .filter(\.$inviteCode == code)
            .with(\.$doodles, { $0.with(\.$entities) })
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", code: code))
    }

    /// Gets all doodles inside a room/document
    static func getAllDoodles(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        getSingleById(id, on: db)
            .flatMapThrowing { $0.getChildren() }
    }

    /// Gets all rooms in the database with all the doodles
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        PersistedDTRoom.query(on: db)
            .with(\.$doodles)
            .all()
    }

    /// Gets all users and their accessible rooms, which contain all entites and doodles inside the room
    static func getRoomDTUserAccesses(_ id: PersistedDTRoom.IDValue?,
                                      on db: Database) -> EventLoopFuture<[PersistedDTUserAccesses]> {
        guard let id = id else {
            return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
        }
        return PersistedDTUserAccesses
            .query(on: db)
            .with(\.$room)
            .with(\.$user, { $0.with(\.$accessibleRooms, { $0.with(\.$doodles, { $0.with(\.$entities) }) }) })
            .filter(\.$room.$id == id)
            .all()
    }

}
