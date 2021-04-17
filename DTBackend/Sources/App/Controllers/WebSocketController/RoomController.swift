import Vapor
import Fluent
import DTSharedLibrary

class RoomController {
    let lock: Lock
    let usersLock: Lock
    var sockets: [UUID: WebSocket]
    var users: [UUID: PersistedDTUser]
    let db: Database
    let logger: Logger

    let roomId: UUID
    let roomController: ActiveRoomController

    init(roomId: UUID, db: Database) {
        self.lock = Lock()
        self.usersLock = Lock()
        self.sockets = [:]
        self.users = [:]
        self.db = db
        self.logger = Logger(label: "RoomController")
        self.roomId = roomId
        self.roomController = ActiveRoomController(roomId: roomId, db: db)
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
    
    
//    func connect(_ ws: WebSocket, userId: String) {
//        PersistedDTUser.getSingleById(userId, on: db).whenComplete { result in
//            switch result {
//            case .success(let user):
//                self.onSuccessfulConnect(ws, user: user)
//            case .failure(let error):
//                // Unable to find user in DB
//                self.logger.error("\(error.localizedDescription)")
//                ws.close()
//            }
//        }
//    }
    
//    func onData(_ ws: WebSocket, _ data: Data) {
//        let decodedData = try decoder.decode(DTMessage.self, from: data)
//        switch decodedData.type {
//        case .disconnect:
//            self.onDisconnect(decodedData.id)
//        case .initiateAction:
//            let newActionData = try decoder.decode(
//                DTInitiateActionMessage.self, from: data)
//            self.onNewAction(ws, decodedData.id, newActionData)
//        case .requestFetch:
//            self.initiateDoodleFetching(ws, decodedData.id)
//        case .clearDrawing:
//            let actionData = try decoder.decode(
//                DTClearDrawingMessage.self, from: data)
//            self.onClearDrawing(ws, decodedData.id, actionData)
//        default:
//            break
//    }
    
    func onDisconnect(_ id: UUID) {
        self.lock.withLockVoid {
            self.sockets[id] = nil
        }
    }

    
    func syncData() {
        let doodles = roomController.doodles
        doodles.forEach { doodle in
            PersistedDTDoodle.getSingleById(doodle.key, on: self.db)
                .flatMapThrowing { res in
                    _ = res.strokes.forEach { $0.delete(on: self.db) }
                }
                .flatMapThrowing {
                    for stroke in doodle.value.strokes {
                        _ = stroke.makePersistedStroke().save(on: self.db)
                    }
                }.whenComplete { res in
                    switch res {
                    case .failure(let err):
                        self.logger.report(error: err)
                    case .success:
                        self.logger.info("Synced doodle \(doodle.key.uuidString)")
                    }
                }
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
                dispatchAction, id: id, to: self.getAllWebSocketOptionsExcept(id), success: true, message: "New Action"
            )
            self.sendActionFeedback(
                orginalAction: action,
                dispatchAction: dispatchAction, id: id,
                to: .id(id), success: true, message: "Action sucessful."
            )
            return
        }

        // action denied

        self.initiateDoodleFetching(ws, id)
        self.sendActionFeedback(
            orginalAction: action,
            dispatchAction: nil, id: id,
            to: .id(id), success: false, message: "Action failed. Please refetch"
        )
    }

    func initiateDoodleFetching(_ ws: WebSocket, _ id: UUID) {
        if !roomController.hasFetchedDoodles {
            PersistedDTRoom.getAllDoodles(roomId, on: self.db)
                .flatMapThrowing { $0.map(DTAdaptedDoodle.init) }
                .whenComplete { res in
                    switch res {
                    case .failure(let err):
                        self.logger.report(error: err)

                    case .success(let doodles):
                        self.logger.info("Fetching existing doodles.")
                        self.sendFetchedDoodles(doodles, id, to: [.socket(ws)])
                    }
                }
        } else {
            self.sendFetchedDoodles(roomController.doodleArray, id, to: [.socket(ws)])
        }
    }

    func sendFetchedDoodles(_ doodles: [DTAdaptedDoodle], _ id: UUID, to sendOptions: [WebSocketSendOption],
                            success: Bool = true, message: String = "") -> (DTFetchDoodleMessage, [WebSocketSendOption]) {
        self.logger.info("Fetched doodles!")
        let message = DTFetchDoodleMessage(
            id: id,
            success: success,
            message: message,
            doodles: doodles
        )
        return (message, sendOptions)
    }

    func dispatchActionToPeers(_ action: DTAdaptedAction, id: UUID, to sendOptions: [WebSocketSendOption],
                               success: Bool = true, message: String = "") -> (DTDispatchActionMessage, [WebSocketSendOption]) {
        self.logger.info("Dispatched an action to peers!")
        let message = DTDispatchActionMessage(
            id: id,
            success: success,
            message: message,
            action: action
        )
        return (message, sendOptions)
    }

    func dispatchClearActionToPeers(_ message: DTClearDrawingMessage,
                                    to sendOptions: [WebSocketSendOption]) -> (DTClearDrawingMessage, [WebSocketSendOption]) {
        self.logger.info("Dispatched a clear action to peers!")
        return (message, sendOptions)
    }

    func sendActionFeedback(orginalAction: DTAdaptedAction, dispatchAction: DTAdaptedAction?,
                            id: UUID, to sendOption: WebSocketSendOption,
                            success: Bool = true, message: String = "",
                            isActionDenied: Bool = false) -> (DTActionFeedbackMessage, [WebSocketSendOption]) {
        let message = DTActionFeedbackMessage(
            id: id,
            success: success,
            message: message,
            orginalAction: orginalAction,
            dispatchedAction: dispatchAction
        )
        let sendOptions = [sendOption]
        return (message, sendOptions)
    }
}
