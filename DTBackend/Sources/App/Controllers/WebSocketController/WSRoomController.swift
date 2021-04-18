import Vapor
import Fluent
import DTSharedLibrary

class WSRoomController {
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

    func getWebSockets(_ sendOptions: [WebSocketSendOption]) -> [WebSocket] {
        self.lock.withLock {
            var webSockets = [WebSocket]()
            for option in sendOptions {
                switch option {
                case .id(let id):
                    webSockets += [self.sockets[id]].compactMap { $0 }
                case .socket(let socket):
                    webSockets += [socket]
                }
            }
            return webSockets
        }
    }

    func onJoinRoom(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTJoinRoomMessage.self, from: data)
            let userId = decodedData.userId
            let wsId = decodedData.id

            PersistedDTUser.getSingleById(userId, on: db)
                .and(PersistedDTRoom.getRoomPermissions(roomId: self.roomId, on: db))
                .whenComplete { result in
                    switch result {
                    case .success(let innerResult):
                        let (user, userAccesses) = innerResult

                        // Register user into room
                        self.registerUser(user: user, wsId: wsId)

                        // Register socket to room
                        self.registerSocket(socket: ws, wsId: wsId)

                        self.dispatchParticipantsInfo(ws, wsId: wsId, userAccesses: userAccesses)

                        // Fetch all existing doodles
                        self.initiateDoodleFetching(ws, wsId)

                    case .failure(let error):
                        // Unable to find user in DB
                        self.logger.error("\(error.localizedDescription)")
                    }
                }
        } catch {
            logger.report(error: error)
        }
    }

    private func registerUser(user: PersistedDTUser, wsId: UUID) {
        self.usersLock.withLockVoid {
            self.logger.info("Adding user: \(user.displayName)")
            self.users[wsId] = user
        }
    }

    private func registerSocket(socket: WebSocket, wsId: UUID) {
        self.lock.withLockVoid {
            self.sockets[wsId] = socket
        }
    }

    private func dispatchParticipantsInfo(_ ws: WebSocket, wsId: UUID, userAccesses: [DTAdaptedUserAccesses]) {
        // Send participant info message
        let message = DTParticipantInfoMessage(
            id: wsId, roomId: self.roomId,
            users: userAccesses
        )
        ws.send(message: message)
    }

    func onRoomMessage(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTRoomMessage.self, from: data)
            switch decodedData.subtype {
            case .exitRoom:
                self.onExitRoom(decodedData.id)
            case .initiateAction:
                let newActionData = try decoder.decode(
                    DTInitiateActionMessage.self, from: data)
                self.onNewAction(ws, decodedData.id, newActionData)
            case .requestFetch:
                self.initiateDoodleFetching(ws, decodedData.id)
            case .addDoodle:
                let createDoodleData = try decoder.decode(
                    DTAdaptedDoodle.CreateRequest.self, from: data)
                self.handleAddDoodle(ws, decodedData.id, createDoodleData)
            case .removeDoodle:
                let removeDoodleData = try decoder.decode(
                    DTRemoveDoodleMessage.self, from: data)
                self.handleRemoveDoodle(ws, decodedData.id, doodleId: removeDoodleData.doodleId)
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

    // MARK: - exitRoom

    func onExitRoom(_ id: UUID) {
        self.lock.withLockVoid {
            self.sockets[id] = nil
            self.users[id] = nil
        }
    }

    // MARK: - initiateAction

    func onNewAction(_ ws: WebSocket, _ id: UUID,
                     _ message: DTInitiateActionMessage) {
        let action = message.action

//        self.logger.info("\(action)")
        // action successful
        if let dispatchAction = roomController.process(action) {
            self.dispatchActionToPeers(
                dispatchAction, id: id, to: self.getAllWebSocketOptionsExcept(id),
                success: true, message: "New Action"
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

    func dispatchActionToPeers(_ action: DTAdaptedAction, id: UUID, to sendOptions: [WebSocketSendOption],
                               success: Bool = true, message: String = "") {
        self.logger.info("Dispatched an action to peers!")
        let message = DTDispatchActionMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            action: action
        )

        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    func sendActionFeedback(orginalAction: DTAdaptedAction, dispatchAction: DTAdaptedAction?,
                            id: UUID, to sendOption: WebSocketSendOption,
                            success: Bool = true, message: String = "",
                            isActionDenied: Bool = false) {
        let message = DTActionFeedbackMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            orginalAction: orginalAction,
            dispatchedAction: dispatchAction
        )
        let sendOptions = [sendOption]
        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    // MARK: - requestFetch

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

    func sendFetchedDoodles(_ doodles: [DTAdaptedDoodle], _ id: UUID,
                            to sendOptions: [WebSocketSendOption],
                            success: Bool = true, message: String = "") {
        self.logger.info("Fetched doodles!")
        let message = DTFetchDoodleMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            doodles: doodles
        )
        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    // MARK: - addDoodle & removeDoodle

    func handleAddDoodle(_ ws: WebSocket, _ id: UUID, _ createDoodleData: DTAdaptedDoodle.CreateRequest) {
        let newDoodle = createDoodleData.makePersistedDoodle()

        newDoodle.save(on: db)
            .flatMap { PersistedDTDoodle.getSingleById(newDoodle.id, on: self.db) }
            .flatMapThrowing(DTAdaptedDoodle.init).whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success(let doodle):
                    self.logger.info("Dispatched an add doodle action to peers!")
                    self.roomController.addDoodle(doodle)
                    let message = DTAddDoodleMessage(id: id, roomId: self.roomId, newDoodle: doodle)
                    self.getWebSockets(self.getAllWebSocketOptionsExcept(id)).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

    func handleRemoveDoodle(_ ws: WebSocket, _ id: UUID, doodleId: UUID) {
        PersistedDTDoodle.getSingleById(doodleId, on: db)
            .flatMap { doodle in
                doodle.delete(on: self.db)
            }.whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success:
                    self.logger.info("Dispatched an remove doodle action to peers!")
                    self.roomController.removeDoodle(doodleId)
                    let message = DTRemoveDoodleMessage(id: id, roomId: self.roomId, doodleId: doodleId)
                    self.getWebSockets(self.getAllWebSocketOptionsExcept(id)).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

    // MARK: - clearDrawing

    func onClearDrawing(_ ws: WebSocket, _ id: UUID, _ message: DTClearDrawingMessage) {
        PersistedDTAction.query(on: self.db).delete().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success:
                self.logger.info("Dispatched a clear action to peers!")
                self.getWebSockets(self.getAllWebSocketOptionsExcept(id)).forEach {
                    $0.send(message: message)
                }
            }
        }
    }

    // MARK: - Data syncing

    func syncData() {
        let doodles = roomController.doodles
        doodles.forEach { doodle in
            PersistedDTDoodle.getSingleById(doodle.key, on: self.db)
                .flatMapThrowing { res in
                    res.strokes.forEach { $0.delete(on: self.db) }
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
}
