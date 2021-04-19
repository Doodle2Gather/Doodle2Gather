import Vapor
import Fluent
import DTSharedLibrary

class WSHomeController {
    let db: Database
    let logger = Logger(label: "WSHomeController")

    init(db: Database) {
        self.db = db
    }

    func onHomeMessage(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTHomeMessage.self, from: data)
            logger.info("Received message: \(decodedData.subtype)")
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
                    let message = DTCreateRoomMessage(id: id, ownerId: request.ownerId, name: request.name, room: room)
                    ws.send(message: message)
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
                    ws.send(message: message)
                }
            }
    }

}
