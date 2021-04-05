import Vapor
import Fluent

struct DTWebSocketController: RouteCollection {
    let db: Database
    private let webSocketsManager: DTWebSocketsManager
    
    init(db: Database) {
        self.db = db
        webSocketsManager = DTWebSocketsManager(db: db)
    }

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("rooms", ":roomId",
                         maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 24),
                         onUpgrade: self.webSocket)
    }

    func webSocket(req: Request, socket: WebSocket) {
        guard let roomId = req.parameters.get("roomId") else {
            req.logger.error("Missing roomId")
            return
        }
        webSocketsManager.directToWebSocketController(socket: socket, roomId: roomId)
        req.logger.info("User joined room \(roomId)")
    }
}

private class DTWebSocketsManager {
    let db: Database
    var wsControllers = [String : WebSocketController]()
    
    init(db: Database) {
        self.db = db
    }
    
    func directToWebSocketController(socket: WebSocket, roomId: String) {
        let wsController = wsControllers[roomId, default: WebSocketController(roomId: roomId, db: db)]
        wsControllers[roomId] = wsController
        wsController.connect(socket)
    }
}
