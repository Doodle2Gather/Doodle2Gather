import Fluent
import Vapor
import DTSharedLibrary

struct DTUserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.User.createUserInfo, use: createUserInfoHandler)
        routes.on(Endpoints.User.readUserInfo, use: readUserInfoHandler)
        routes.on(Endpoints.User.readUserRoomsInfo, use: readUserRoomsInfoHandler)
        routes.on(Endpoints.User.updateUserInfo, use: updateUserInfoHandler)
        routes.on(Endpoints.User.deleteUserInfo, use: deleteUserInfoHandler)
    }

    func createUserInfoHandler(req: Request) throws -> EventLoopFuture<DTAdaptedUser> {
        try PersistedDTUser.createUserInfo(req: req).flatMapThrowing(DTAdaptedUser.init)
    }

    func readUserInfoHandler(req: Request) throws -> EventLoopFuture<DTAdaptedUser> {
        try PersistedDTUser.readUserInfo(req: req).flatMapThrowing(DTAdaptedUser.init)
    }

    func readUserRoomsInfoHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedUserAccesses]> {
        try PersistedDTUser.readUserRoomsInfo(req: req).flatMapThrowing{ $0.map { DTAdaptedUserAccesses(userAccesses: $0) }
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

extension PersistedDTUser {

    static func getSingleById(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTUser> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTUser"))
      }
      return PersistedDTUser.query(on: db)
        .filter(\.$id == id)
        .with(\.$accessibleRooms)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTUser", id: id))
    }

    static func getAllRooms(_ id: PersistedDTUser.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        getSingleById(id, on: db)
            .flatMapThrowing { $0.accessibleRooms }
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTUser]> {
        PersistedDTUser.query(on: db)
            .with(\.$accessibleRooms)
            .all()
    }

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
    
    static func readUserRoomsInfo(req: Request) throws -> EventLoopFuture<[PersistedDTUserAccesses]> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return PersistedDTUserAccesses
            .query(on: req.db)
            .filter(\.$user.$id == id)
            .all()
    }
}
