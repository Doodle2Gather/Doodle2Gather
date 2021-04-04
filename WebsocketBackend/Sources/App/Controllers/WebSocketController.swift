import Vapor
import Fluent
import DoodlingAdaptedLibrary

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

    func getAllWebSocketOptionsExcept(_ uuid: UUID) -> [WebSocketSendOption] {
        var options = [WebSocketSendOption]()
        for ws in sockets where ws.key != uuid {
            options.append(.socket(ws.value))
        }
        return options
    }

    func connect(_ ws: WebSocket) {
        let uuid = UUID()
        self.lock.withLockVoid {
            self.sockets[uuid] = ws
        }
        ws.onBinary { [weak self] ws, buffer in
            guard let self = self, let data = buffer.getData(
                    at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }
            self.onData(ws, data)
        }
        ws.onText { [weak self] ws, text in
            guard let self = self, let data = text.data(using: .utf8) else {
                return
            }
            self.onData(ws, data)
        }
        self.send(message: DTHandshake(id: uuid), to: [.socket(ws)])

        // TODO: replace with RESTful route
        PersistedDTAction.query(on: self.db).all().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)

            case .success(let actions):
                self.logger.info("Load existing action. Action count: \(actions.count)")
                actions.forEach {
                    self.dispatchActionToPeers($0, to: [.socket(ws)])
                }
            }
        }
    }

    func onData(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTMessage.self, from: data)
            switch decodedData.type {
            case .initiateAction:
                let newActionData = try decoder.decode(
                    DTInitiateActionMessage.self, from: data)
                self.onNewAction(ws, decodedData.id, newActionData)
            case .clearDrawing:
                let actionData = try decoder.decode(
                    DTClearDrawingMessage.self, from: data)
                self.onClearDrawing(ws, decodedData.id, actionData)
            default:
                break
            }
        } catch {
            logger.report(error: error)
        }
    }

    func onClearDrawing(_ ws: WebSocket, _ id: UUID, _ message: DTClearDrawingMessage) {
        PersistedDTAction.query(on: self.db).delete().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success:
                self.dispatchClearActionToPeers(
                    message, to: self.getAllWebSocketOptionsExcept(id)
                )
            }
        }
    }

    func onNewAction(_ ws: WebSocket, _ id: UUID, _ message: DTInitiateActionMessage) {
        let action = message.action.makePersistedAction()

        let autoMerge = AutoMergeController(
            db: self.db, newAction: message.action, persistedAction: action
        )

        autoMerge.perform().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success(let (isActionDenied, success)):
                if !isActionDenied {
                    let message = success ? "Action added" : "Something went wrong adding the action."
                    self.dispatchActionToPeers(
                        action, to: self.getAllWebSocketOptionsExcept(id), success: true, message: message
                    )
                    self.sendActionFeedback(
                        action, to: .id(id), success: success, message: message
                    )
                    return
                }

                self.logger.info("There is a merge conflict. ")
                self.sendActionFeedback(
                    action, to: .id(id), success: success, message: "There is a merge conflict",
                    isActionDenied: isActionDenied, actionHistories: []
                )
                // autoMerge.getLatestDispatchedActions().whenComplete { res in
                //    switch res {
                //    case .failure(let err):
                //        self.logger.report(error: err)
                //    case .success(let actions):
                //        self.sendActionFeedback(
                //            action, to: .id(id), success: success, message: "There is a merge conflict",
                //            isActionDenied: isActionDenied, actionHistories: actions
                //        )
                //    }
                // }
            }
        }
    }

    func send<T: Codable>(message: T, to sendOption: [WebSocketSendOption]) {
        logger.info("Sending \(T.self) to \(sendOption)")
        do {
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

            let encoder = JSONEncoder()
            let data = try encoder.encode(message)

            sockets.forEach {
                $0.send(raw: data, opcode: .binary)
            }
        } catch {
            logger.report(error: error)
        }
    }

    func dispatchActionToPeers(_ action: PersistedDTAction, to sendOptions: [WebSocketSendOption],
                               success: Bool = true, message: String = "") {
        self.logger.info("Dispatched an action to peers!")
        try? self.send(message: DTDispatchActionMessage(
            success: success,
            message: message,
            id: action.requireID(),
            createdAt: action.createdAt,
            action: DTAdaptedAction(action: action)
        ), to: sendOptions)
    }

    func dispatchClearActionToPeers(_ message: DTClearDrawingMessage, to sendOptions: [WebSocketSendOption]) {
        self.logger.info("Dispatched a clear action to peers!")
        self.send(message: message, to: sendOptions)
    }

    func sendActionFeedback(_ action: PersistedDTAction, to sendOption: WebSocketSendOption,
                            success: Bool = true, message: String = "",
                            isActionDenied: Bool = false,
                            actionHistories: [DTAdaptedAction] = []) {
        self.logger.info("Sent an action feedback!")
        try? self.send(message: DTActionFeedbackMessage(
            success: success,
            message: message,
            id: action.requireID(),
            createdAt: action.createdAt,
            action: DTAdaptedAction(action: action),
            isActionDenied: isActionDenied,
            actionHistories: actionHistories
        ), to: [sendOption])
    }
}
