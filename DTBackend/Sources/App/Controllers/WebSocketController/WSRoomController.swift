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
        self.logger = Logger(label: "WSRoomController")

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

            PersistedDTUser.getSingleById(userId, on: db).whenComplete { result in
                switch result {
                case .success(let user):
                    var oldUsers = [PersistedDTUser]()
                    self.usersLock.withLockVoid {
                        oldUsers = Array(self.users.values)
                        self.logger.info("Old users: \(oldUsers.map { $0.displayName })")
                        self.logger.info("Adding user: \(user.displayName)")
                        self.users[wsId] = user
                    }
                    self.lock.withLockVoid {
                        self.sockets[wsId] = ws
                    }
                    let message = DTParticipantInfoMessage(
                        id: wsId, roomId: self.roomId,
                        users: oldUsers.map { DTAdaptedUser(user: $0) }
                    )

                    // send participant info
                    self.getWebSockets([.socket(ws)]).forEach {
                        $0.send(message: message)
                    }

                    // fetch all existing doodles
                    self.handleDoodleFetching(ws, wsId)

                case .failure(let error):
                    // Unable to find user in DB
                    self.logger.error("\(error.localizedDescription)")
                }
            }
        } catch {
            logger.report(error: error)
        }
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
