import Vapor
import Fluent
import DTSharedLibrary

enum WebSocketSendOption {
    case id(UUID), socket(WebSocket)
}

class WebSocketController {
    private var logger = Logger(label: "WebSocketController")
    private let lock: Lock
    private let db: Database
    private var sockets: [UUID: WebSocket]
    private var authController: WSAuthController
    private var homeController: WSHomeController
    private var roomControllers: [UUID: WSRoomController]

    init(db: Database) {
        self.lock = Lock()
        self.db = db
        self.logger = Logger(label: "WebSocketController")
        self.sockets = [:]
        self.authController = WSAuthController(db: db)
        self.homeController = WSHomeController(db: db)
        self.roomControllers = [:]
        self.homeController.delegate = self
    }

    func onConnect(_ ws: WebSocket) {
        let uuid = UUID()
        self.lock.withLockVoid {
            self.sockets[uuid] = ws
        }
        logger.info("New client connected. UUID: \(uuid.uuidString)")
        ws.send(message: DTHandshake(id: uuid))
    }

    /// Relay all messages received from the clients to respective controllers
    func onData(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(DTMessage.self, from: data)
            switch message.type {
            case .auth:
                authController.onAuthMessage(ws, data)
            case .home:
                homeController.onHomeMessage(ws, data)
            case .room:
                handleRoomMessages(ws, wsId: message.id, data: data)
            default:
                logger.warning("Unrecognized message type: \(message.type) from \(message.id)")
            }
        } catch {
            logger.report(error: error)
        }
    }

    private func handleRoomMessages(_ ws: WebSocket, wsId: UUID, data: Data) {
        let decoder = JSONDecoder()
        do {
            let roomMessage = try decoder.decode(DTRoomMessage.self, from: data)
            if roomMessage.subtype == .joinRoom {
                if roomControllers[roomMessage.roomId] == nil {
                    roomControllers[roomMessage.roomId] = WSRoomController(roomId: roomMessage.roomId, db: db)
                }
                guard let roomController = roomControllers[roomMessage.roomId] else {
                    // actually, we can force unwrap here rather safely, but we will play safe
                    fatalError("Unable to fetch room controller")
                }
                roomController.onJoinRoom(ws, data)
                return
            }
            if roomMessage.subtype == .exitRoom {
                guard let roomController = roomControllers[roomMessage.roomId] else {
                    // actually, we can force unwrap here rather safely, but we will play safe
                    fatalError("Unable to fetch room controller")
                }
                roomController.handleExitRoom(roomMessage.id)
                if roomController.sockets.isEmpty {
                    self.logger.info("Closing empty room")
                    roomControllers[roomMessage.roomId] = nil
                }
                return
            }

            guard let roomController = roomControllers[roomMessage.roomId] else {
                let warningMessage = "Received message to non-existent room controller. " +
                    "Room ID: \(roomMessage.roomId) From: \(wsId)"
                logger.warning("\(warningMessage)")
                return
            }
            roomController.onRoomMessage(ws, data)

        } catch {
            logger.warning("Unable to decode room message. From: \(wsId), Error: \(error.localizedDescription)")
            return
        }
    }

    func onDisconnect(_ id: UUID) {
        self.lock.withLockVoid {
            self.sockets[id] = nil
        }
    }
}

extension WebSocketController: WSHomeControllerDelegate {
    func didJoinRoomViaInvite(roomId: UUID) {
        if let openRoom = self.roomControllers[roomId] {
            openRoom.updateParticipantsInfo()
        }
    }
}
