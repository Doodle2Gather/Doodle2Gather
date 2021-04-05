import Fluent
import Vapor
import DTSharedLibrary

struct DTUserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.User.createUserInfo, use: createUserInfoHandler)
//        routes.on(Endpoints.User.readUserInfo, use: readUserInfoHandler)
//        routes.on(Endpoints.User.updateUserInfo, use: updateUserInfoHandler)
//        routes.on(Endpoints.User.deleteUserInfo, use: deleteUserInfoHandler)
    }
    
    func createUserInfoHandler(req: Request) throws -> EventLoopFuture<PersistedDTUser> {
        let newDTUser = try req.content.decode(PersistedDTUser.self)
        return newDTUser.save(on: req.db).map { newDTUser }
    }
}
