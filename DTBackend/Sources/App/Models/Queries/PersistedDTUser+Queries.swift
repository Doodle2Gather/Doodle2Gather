import Fluent
import Vapor
import DTSharedLibrary

/// Contains all the queries on `PersistedDTUser` that return Adapted models
extension PersistedDTUser {

    /// Gets all rooms which are acessible by the given user
    static func getAllAccessibleRooms(userId: String, on db: Database) -> EventLoopFuture<[DTAdaptedRoom]> {
        PersistedDTUser.getAllRooms(userId, on: db)
            .flatMapThrowing {
                $0.map { DTAdaptedRoom(room: $0 ) }
            }
    }
}

/// Contains all the queries on `PersistedDTUser`that return Persisted models
extension PersistedDTUser {

    /// Gets a user by user id
    static func getSingleById(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTUser> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTUser"))
      }
      return PersistedDTUser.query(on: db)
        .filter(\.$id == id)
        .with(\.$accessibleRooms, { $0.with(\.$doodles, { $0.with(\.$entities) }) })
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTUser", id: id))
    }

    /// Gets all users and their accessible rooms in the database
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTUser]> {
        PersistedDTUser.query(on: db)
            .with(\.$accessibleRooms)
            .all()
    }

    /// Gets all rooms which are accessible by the given user
    static func getAllRooms(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        guard let id = id else {
          return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTUser"))
        }
        return getSingleById(id, on: db)
            .flatMapThrowing { $0.getAccessibleRooms() }
    }

}
