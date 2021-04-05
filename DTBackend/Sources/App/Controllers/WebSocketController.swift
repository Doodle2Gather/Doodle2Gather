import Vapor
import Fluent
import DTSharedLibrary

enum WebSocketSendOption {
    case id(UUID), socket(WebSocket)
}

class WebSocketController {
    let lock: Lock
    var sockets: [UUID: WebSocket]
    let db: Database
    let logger: Logger

    let roomController: ActiveRoomController

    init(db: Database) {
        self.lock = Lock()
        self.sockets = [:]
        self.db = db
        self.logger = Logger(label: "WebSocketController")
        self.roomController = ActiveRoomController(db: db)
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
//        PersistedDTAction.query(on: self.db).all().whenComplete { res in
//            switch res {
//            case .failure(let err):
//                self.logger.report(error: err)
//
//            case .success(let actions):
//                self.logger.info("Load existing action. Action count: \(actions.count)")
//                actions.forEach {
//                    self.dispatchActionToPeers($0, to: [.socket(ws)])
//                }
//            }
//        }
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
        let action = message.action

        // action successful
        if let dispatchAction = roomController.process(action) {
            self.dispatchActionToPeers(
                dispatchAction, to: self.getAllWebSocketOptionsExcept(id), success: true, message: "New Action"
            )
            self.sendActionFeedback(
                orginalAction: action,
                dispatchAction: dispatchAction,
                to: .id(id), success: true, message: "Action sucessful."
            )
            return
        }

        // action denied

        self.sendActionFeedback(
            orginalAction: action,
            dispatchAction: nil,
            to: .id(id), success: false, message: "Action failed. Please refetch"
        )
    }

    func syncData() {
        let activeRooms = roomController.activeRooms
        for room in activeRooms {
            PersistedDTRoom.getSingleByID(room.key, on: self.db).map { $0.delete(on: self.db) }

            // TODO: - Sync all active room data to db

            for doodle in room.value {

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

    func dispatchActionToPeers(_ action: DTAdaptedAction, to sendOptions: [WebSocketSendOption],
                               success: Bool = true, message: String = "") {
        self.logger.info("Dispatched an action to peers!")
        self.send(message: DTDispatchActionMessage(
            success: success,
            message: message,
            action: action
        ), to: sendOptions)
    }

    func dispatchClearActionToPeers(_ message: DTClearDrawingMessage, to sendOptions: [WebSocketSendOption]) {
        self.logger.info("Dispatched a clear action to peers!")
        self.send(message: message, to: sendOptions)
    }

    func sendActionFeedback(orginalAction: DTAdaptedAction, dispatchAction: DTAdaptedAction?,
                            to sendOption: WebSocketSendOption,
                            success: Bool = true, message: String = "",
                            isActionDenied: Bool = false) {
        self.send(message: DTActionFeedbackMessage(
            success: success,
            message: message,
            orginalAction: orginalAction,
            dispatchedAction: dispatchAction
        ), to: [sendOption])
    }
}
