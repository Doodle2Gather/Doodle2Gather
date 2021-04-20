import Vapor
import Fluent
import DTSharedLibrary

class WSRoomController {
    let lock = Lock()
    let usersLock = Lock()
    var sockets = [UUID: WebSocket]()
    var users = [UUID: PersistedDTUser]() {
        didSet {
            DispatchQueue.global().async {
                self.broadcastLiveState()
            }
        }
    }

    let db: Database
    let logger = Logger(label: "WSRoomController")

    let roomId: UUID
    let roomController: ActiveRoomController

    init(roomId: UUID, db: Database) {
        self.db = db
        self.roomId = roomId
        self.roomController = ActiveRoomController(roomId: roomId, db: db)
    }

    func broadcastLiveState() {
        var usersInRoom = [DTAdaptedUser]()
        self.usersLock.withLockVoid {
            usersInRoom = users.values.map { $0.toDTAdaptedUser(withRooms: false) }
        }
        let message = DTRoomLiveStateMessage(roomId: self.roomId, usersInRoom: usersInRoom)
        self.getWebSockets(self.getAllWebSocketOptions).forEach {
            $0.send(message: message)
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

                        // Register socket to room
                        self.registerSocket(socket: ws, wsId: wsId)

                        // Register user into room
                        self.registerUser(user: user, wsId: wsId)

                        // fetch all existing doodles
                        self.handleDoodleFetching(ws, wsId)
                        self.dispatchParticipantsInfo(ws, wsId: wsId, userAccesses: userAccesses)

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
                self.handleExitRoom(decodedData.id)
            case .initiateAction:
                let newActionData = try decoder.decode(
                    DTInitiateActionMessage.self, from: data)
                self.handleNewAction(ws, decodedData.id, newActionData)
            case .requestFetch:
                self.handleDoodleFetching(ws, decodedData.id)
            case .requestAddDoodle:
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
                self.handleClearDrawing(ws, decodedData.id, actionData)
            default:
                break
            }
        } catch {
            logger.report(error: error)
        }
    }

    // MARK: - Data syncing

    func syncData() {
        let doodles = roomController.doodles
        doodles.forEach { doodle in
            PersistedDTDoodle.getSingleById(doodle.key, on: self.db)
                .flatMapThrowing { res in
                    res.getEntities().forEach { _ = $0.delete(on: self.db) }
                }
                .flatMapThrowing {
                    for stroke in doodle.value.strokes {
                        _ = stroke.makePersistedStroke().save(on: self.db)
                    }
                    for text in doodle.value.text {
                        _ = text.makePersistedText().save(on: self.db)
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

// MARK: - Broadcast Helpers
extension WSRoomController {
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
}
