import Vapor
import Fluent
import DTSharedLibrary

enum WebSocketSendOption {
    case id(UUID), socket(WebSocket)
}

class WebSocketController {
    let lock: Lock
    let usersLock: Lock
    var sockets: [UUID: WebSocket]
    var users: [UUID: PersistedDTUser]
    let db: Database
    let logger: Logger

    let roomControllers: [UUID: RoomController]
    

    init(roomId: UUID, db: Database) {
        self.lock = Lock()
        self.usersLock = Lock()
        self.sockets = [:]
        self.users = [:]
        self.db = db
        self.logger = Logger(label: "WebSocketController")

        self.roomControllers = [:]
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

    func connect(_ ws: WebSocket, userId: String) {
        PersistedDTUser.getSingleById(userId, on: db).whenComplete { result in
            switch result {
            case .success(let user):
                self.onSuccessfulConnect(ws, user: user)
            case .failure(let error):
                // Unable to find user in DB
                self.logger.error("\(error.localizedDescription)")
                ws.close()
            }
        }
    }

    private func onSuccessfulConnect(_ ws: WebSocket, user: PersistedDTUser) {
        let uuid = UUID()
        var oldUsers = [PersistedDTUser]()
        self.usersLock.withLockVoid {
            oldUsers = Array(users.values)
            logger.info("Old users: \(oldUsers.map { $0.displayName })")
            logger.info("Adding user: \(user.displayName)")
            users[uuid] = user
        }
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
        self.send(message: DTHandshake(id: uuid, users: oldUsers.map { DTAdaptedUser(user: $0) }), to: [.socket(ws)])

//        self.initiateDoodleFetching(ws, uuid)
    }

    func onData(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()

        do {

        } catch {
            logger.report(error: error)
        }
    }

    func onDisconnect(_ id: UUID) {
        self.lock.withLockVoid {
            self.sockets[id] = nil
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
}
