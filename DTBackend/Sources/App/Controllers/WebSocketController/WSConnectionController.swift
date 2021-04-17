import Vapor
import Fluent
import DTSharedLibrary

struct WSConnectionController: RouteCollection {
    let db: Database
    private let webSocketsManager: DTWebSocketsManager

    init(db: Database) {
        self.db = db
        webSocketsManager = DTWebSocketsManager(db: db)
    }

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("rooms", ":roomId", ":userId",
                         maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 24),
                         onUpgrade: self.webSocket)
    }

    func webSocket(req: Request, socket: WebSocket) {
        guard let roomId = req.parameters.get("roomId") else {
            req.logger.error("Missing roomId")
            return
        }
        guard let userId = req.parameters.get("userId") else {
            req.logger.error("Missing userId")
            return
        }
        guard let id = UUID(uuidString: roomId) else {
            req.logger.error("Invalid roomId")
            return
        }
        webSocketsManager.directToWebSocketController(socket: socket, roomId: id, userId: userId)
        req.logger.info("User \(userId) joined room \(id.uuidString)")
    }
}

private class DTWebSocketsManager {
    let db: Database
    var wsControllers = [UUID: WebSocketController]()

    init(db: Database) {
        self.db = db
    }

    func directToWebSocketController(socket: WebSocket, roomId: UUID, userId: String) {
        let wsController = wsControllers[roomId, default: WebSocketController(roomId: roomId, db: db)]
        wsControllers[roomId] = wsController
        wsController.connect(socket, userId: userId)
    }
}