import Vapor
import Fluent
import DTSharedLibrary

class WSHomeController {

    let lock: Lock
    let usersLock: Lock
    var sockets: [UUID: WebSocket]
    var users: [UUID: PersistedDTUser]
    let db: Database
    let logger: Logger

    init(db: Database) {
        self.lock = Lock()
        self.usersLock = Lock()
        self.sockets = [:]
        self.users = [:]
        self.db = db
        self.logger = Logger(label: "WSHomeController")
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

    func onHomeMessage(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTHomeMessage.self, from: data)
            switch decodedData.subtype {
            case .createRoom:
                let createRoomData = try decoder.decode(
                    DTAdaptedRoom.CreateRequest.self, from: data)
                self.handleCreateRoom(ws, decodedData.id, createRoomData)
//            case .joinViaInvite:
//                self.handleJoinViaInvite(decodedData.id)
            case .accessibleRooms:
                let messageData = try decoder.decode(
                    DTAccessibleRoomMessage.self, from: data)
                self.handleAccessibleRooms(ws, decodedData.id, messageData)
            default:
                break
            }
        } catch {
            logger.report(error: error)
        }
    }

    func handleCreateRoom(_ ws: WebSocket, _ id: UUID,
                          _ request: DTAdaptedRoom.CreateRequest) {
        PersistedDTRoom.createRoom(request, on: db)
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)

                case .success(let room):
                    self.logger.info("Created room.")
                    let message = DTCreateRoomMessage(id: id, ownerId: request.ownerId, room: room)
                    self.getWebSockets([.socket(ws)]).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

    func handleJoinViaInvite(_ ws: WebSocket, _ id: UUID,
                             _ message: DTJoinRoomViaInviteMessage) {

    }

    func handleAccessibleRooms(_ ws: WebSocket, _ id: UUID,
                               _ message: DTAccessibleRoomMessage) {
        PersistedDTUser.getAllAccessibleRooms(userId: message.userId, on: db)
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)

                case .success(let rooms):
                    self.logger.info("Fetching accessible rooms.")
                    let message = DTAccessibleRoomMessage(id: id, userId: message.userId, rooms: rooms)
                    self.getWebSockets([.socket(ws)]).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

}
