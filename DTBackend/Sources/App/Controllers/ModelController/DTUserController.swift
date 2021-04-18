import Fluent
import Vapor
import DTSharedLibrary

struct DTUserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.User.createUserInfo, use: createUserInfoHandler)
        routes.on(Endpoints.User.readUserInfo, use: readUserInfoHandler)
        routes.on(Endpoints.User.getAllRooms, use: getAllRoomsHandler)
        routes.on(Endpoints.User.updateUserInfo, use: updateUserInfoHandler)
        routes.on(Endpoints.User.deleteUserInfo, use: deleteUserInfoHandler)
    }

    func createUserInfoHandler(req: Request) throws -> EventLoopFuture<DTAdaptedUser> {
        try PersistedDTUser.createUserInfo(req: req).flatMapThrowing(DTAdaptedUser.init)
    }

    func readUserInfoHandler(req: Request) throws -> EventLoopFuture<DTAdaptedUser> {
        try PersistedDTUser.readUserInfo(req: req).flatMapThrowing(DTAdaptedUser.init)
    }

    func getAllRoomsHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedRoom]> {
        try PersistedDTUser.getAllRooms(req: req)
            .flatMapThrowing { $0.map { DTAdaptedRoom(room: $0 ) }
            }
    }

    func updateUserInfoHandler(req: Request) throws -> EventLoopFuture<PersistedDTUser> {
           guard let id = req.parameters.get("id") else {
               throw Abort(.badRequest)
           }
           let newDTUser = try req.content.decode(PersistedDTUser.self)
           return PersistedDTUser.find(id, on: req.db)
               .unwrap(or: Abort(.notFound))
               .flatMap { oldDTUser in
                   oldDTUser.update(copy: newDTUser)
                   return oldDTUser.save(on: req.db)
                       .map { oldDTUser }
               }
       }

       func deleteUserInfoHandler(req: Request) throws -> EventLoopFuture<HTTPStatus> {
           guard let id = req.parameters.get("id") else {
               throw Abort(.badRequest)
           }

           return PersistedDTUser.find(id, on: req.db)
               .unwrap(or: Abort(.notFound))
               .flatMap { $0.delete(on: req.db) }
               .transform(to: .ok)
       }
}

// contains all the queries that return Adapted models
extension PersistedDTUser {

    static func getAllAccessibleRooms(userId: String, on db: Database) -> EventLoopFuture<[DTAdaptedRoom]> {
        PersistedDTUser.getAllRooms(userId, on: db)
            .flatMapThrowing {
                $0.map { DTAdaptedRoom(room: $0 ) }
            }
    }

}

// contains all the queries that return Persisted models
extension PersistedDTUser {

    static func getSingleById(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTUser> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTUser"))
      }
      return PersistedDTUser.query(on: db)
        .filter(\.$id == id)
        .with(\.$accessibleRooms, { $0.with(\.$doodles, { $0.with(\.$strokes) }) })
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
