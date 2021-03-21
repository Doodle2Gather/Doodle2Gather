import Vapor
import Fluent

enum WebSocketSendOption {
    case id(UUID), socket(WebSocket)
}

class WebSocketController {
    let lock: Lock
    var sockets: [UUID: WebSocket]
    let db: Database
    let logger: Logger

    init(db: Database) {
        self.lock = Lock()
        self.sockets = [:]
        self.db = db
        self.logger = Logger(label: "WebSocketController")
    }

    var getAllWebSocketOptions: [WebSocketSendOption] {
        var options = [WebSocketSendOption]()
        for ws in sockets {
            options.append(.socket(ws.value))
        }
        return options
    }

    func connect(_ ws: WebSocket) {
        // 1
        let uuid = UUID()
        self.lock.withLockVoid {
            self.sockets[uuid] = ws
        }
        // 2
        ws.onBinary { [weak self] ws, buffer in
            guard let self = self, let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else { return }
            self.onData(ws, data)
        }
        // 3
        ws.onText { [weak self] ws, text in
            guard let self = self, let data = text.data(using: .utf8) else { return }
            self.onData(ws, data)
        }
        // 4
        self.send(message: DoodleActionHandShake(id: uuid), to: [.socket(ws)])

        DoodleAction.query(on: self.db).all().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)

            case .success(let actions):
                self.logger.info("Load existing action. Action count: \(actions.count)")
                actions.forEach {
                    self.sendActionToSockets($0, to: [.socket(ws)])
                }
            }
        }
    }

    func send<T: Codable>(message: T, to sendOption: [WebSocketSendOption]) {
        logger.info("Sending \(T.self) to \(sendOption)")
        do {
            // 1
            let sockets: [WebSocket] = self.lock.withLock {
                var webSockets = [WebSocket]()
                for option in sendOption {
                    switch option {
                    case .id(let id):
                        webSockets += [self.sockets[id]].compactMap { $0 }
                    case .socket(let socket):
                        webSockets += [socket]
                    }
                }
                return webSockets
            }

            // 2
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)

            // 3
            sockets.forEach {
                $0.send(raw: data, opcode: .binary)
            }
        } catch {
            logger.report(error: error)
        }
    }

    func onData(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            // 1
            let decodedData = try decoder.decode(DoodleActionMessageData.self, from: data)
            // 2
            switch decodedData.type {
            case .newAction:
                // 3
                let newActionData = try decoder.decode(
                    NewDoodleActionMessage.self, from: data)
                self.onNewAction(ws, decodedData.id, newActionData)
            default:
                break
            }
        } catch {
            logger.report(error: error)
        }
    }

    func onNewAction(_ ws: WebSocket, _ id: UUID, _ message: NewDoodleActionMessage) {
        let action = DoodleAction(content: message.content, createdBy: id)
        self.db.withConnection {
            // 1
            action.save(on: $0)
        }.whenComplete { res in
            let success: Bool
            let message: String
            switch res {
            case .failure(let err):
                // 2
                self.logger.report(error: err)
                success = false
                message = "Something went wrong adding the action."
            case .success:
                // 3
                self.logger.info("Got a new action!")
                success = true
                message = "Action added"
            }
            // 4
            self.sendActionToSockets(action, to: self.getAllWebSocketOptions, success: success, message: message)
        }
    }

    func sendActionToSockets(_ action: DoodleAction, to sendOptions: [WebSocketSendOption],
                             success: Bool = true, message: String = "") {
        self.logger.info("Sent an action response!")
        try? self.send(message: NewDoodleActionResponse(
            success: success,
            message: message,
            id: action.requireID(),
            content: action.content,
            createdAt: action.createdAt
        ), to: sendOptions)
    }
}
