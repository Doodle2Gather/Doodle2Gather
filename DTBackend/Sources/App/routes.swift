import Vapor
import DTSharedLibrary

func routes(_ app: Application) throws {
    try app.register(collection: DTWebSocketController(db: app.db))

    let api = app.grouped("api")
    try api.grouped(Endpoints.Action.root.toPathComponents).register(collection: DTActionController())
    try api.grouped(Endpoints.Stroke.root.toPathComponents).register(collection: DTStrokeController())
    try api.grouped(Endpoints.User.root.toPathComponents).register(collection: DTUserController())

    app.post("login") { req -> LoginResponse in
        do {
            let loginRequest = try req.content.decode(LoginRequest.self)
            guard loginRequest.password == "goodpassword" else {
                throw Abort(.unauthorized, reason: "Invalid credentials")
            }
            return LoginResponse()
        } catch is DecodingError {
            throw Abort(.badRequest, reason: "Request must have username and password")
        }
    }

}
