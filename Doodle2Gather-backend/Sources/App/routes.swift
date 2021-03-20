import Fluent
import Vapor

func routes(_ app: Application) throws {
    let webSocketController = WebSocketController(db: app.db)
    try app.register(collection: DoodleActionController(wsController: webSocketController))
    
    // 1
    app.post("api", "actions") { req -> EventLoopFuture<DoodleAction> in
        // 2
        let action = try req.content.decode(DoodleAction.self)
        // 3
        return action.save(on: app.db).map {
            // 4
            action
        }
    }
    
}
