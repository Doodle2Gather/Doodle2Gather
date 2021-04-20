import Vapor
import Fluent
import DTSharedLibrary

protocol WSHomeControllerDelegate: AnyObject {
    func didJoinRoomViaInvite(roomId: UUID)
}

/// Handles all `DTHomeMessage` sent between the clients and the server
class WSHomeController {
    let db: Database
    let logger = Logger(label: "WSHomeController")
    private let decoder = JSONDecoder()
    weak var delegate: WSHomeControllerDelegate?

    init(db: Database) {
        self.db = db
    }

    func onHomeMessage(_ ws: WebSocket, _ data: Data) {
        do {
            let decodedData = try decoder.decode(DTHomeMessage.self, from: data)
            logger.info("Received message: \(decodedData.subtype)")
            switch decodedData.subtype {
            case .createRoom:
                try self.handleCreateRoom(ws, data)
            case .joinViaInvite:
                try self.handleJoinViaInvite(ws, data)
            case .accessibleRooms:
                try self.handleAccessibleRooms(ws, data)
            }
        } catch {
            logger.report(error: error)
        }
    }

    func handleCreateRoom(_ ws: WebSocket, _ data: Data) throws {
        let createRoomMessage = try decoder.decode(DTCreateRoomMessage.self, from: data)
        let request = try decoder.decode(DTAdaptedRoom.CreateRequest.self, from: data)
        let id = createRoomMessage.id
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

    func handleJoinViaInvite(_ ws: WebSocket, _ data: Data) throws {
        let joinRequest = try decoder.decode(DTJoinRoomViaInviteMessage.self, from: data)
        PersistedDTRoom.joinRoomViaInvite(joinRequest, on: db).whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
                // Send failure to create room message
                ws.send(message: joinRequest)
            case .success(let room):
                self.logger.info("Joined via invite.")
                var message = joinRequest
                message.joinedRoom = room
                ws.send(message: message)
                guard let roomId = room.roomId else {
                    fatalError("Unable to get roomId")
                }
                self.delegate?.didJoinRoomViaInvite(roomId: roomId)
            }
        }
    }

    func handleAccessibleRooms(_ ws: WebSocket, _ data: Data) throws {
        let message = try decoder.decode(
            DTAccessibleRoomMessage.self, from: data)
        PersistedDTUser.getAllAccessibleRooms(userId: message.userId, on: db)
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)

                case .success(let rooms):
                    self.logger.info("Fetching accessible rooms.")
                    let response = DTAccessibleRoomMessage(id: message.id, userId: message.userId, rooms: rooms)
                    ws.send(message: response)
                }
            }
    }

}
