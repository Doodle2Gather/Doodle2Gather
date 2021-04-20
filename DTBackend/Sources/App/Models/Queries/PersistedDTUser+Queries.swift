import Fluent
import Vapor
import DTSharedLibrary

/// Contains all the queries on `PersistedDTUser` that return Adapted models
extension PersistedDTUser {

    static func getAllAccessibleRooms(userId: String, on db: Database) -> EventLoopFuture<[DTAdaptedRoom]> {
        PersistedDTUser.getAllRooms(userId, on: db)
            .flatMapThrowing {
                $0.map { DTAdaptedRoom(room: $0 ) }
            }
    }
}

/// Contains all the queries on `PersistedDTUser`that return Persisted models
extension PersistedDTUser {

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

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTUser]> {
        PersistedDTUser.query(on: db)
            .with(\.$accessibleRooms)
            .all()
    }

    static func getAllRooms(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        guard let id = id else {
          return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTUser"))
        }
        return getSingleById(id, on: db)
            .flatMapThrowing { $0.getAccessibleRooms() }
    }

    // req should not be used in Persisted model

    static func createUserInfo(req: Request) throws -> EventLoopFuture<PersistedDTUser> {
        let create = try req.content.decode(DTAdaptedUser.CreateRequest.self)
        let newUser = create.makePersistedUser()
        return newUser.save(on: req.db)
            .flatMap { PersistedDTUser.getSingleById(create.id, on: req.db) }
    }

    static func readUserInfo(req: Request) throws -> EventLoopFuture<PersistedDTUser> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return PersistedDTUser.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    static func getAllRooms(req: Request) throws -> EventLoopFuture<[PersistedDTRoom]> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return getSingleById(id, on: req.db)
            .flatMapThrowing { $0.getAccessibleRooms() }
    }
}
