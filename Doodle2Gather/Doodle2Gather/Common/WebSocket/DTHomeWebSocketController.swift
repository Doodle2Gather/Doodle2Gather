import DTSharedLibrary
import Foundation

protocol DTHomeWebSocketControllerDelegate: AnyObject {
    func didGetAccessibleRooms(newRooms: [DTAdaptedRoom])
}

protocol DTNewDocumentWebSocketControllerDelegate: AnyObject {
    func didCreateRoom(newRoom: DTAdaptedRoom)
    func didFailToJoinRoom()
    func didJoinRoomFromInvite(joinedRoom: DTAdaptedRoom)
}

final class DTHomeWebSocketController: DTSendableWebSocketSubController {
    var parentController: DTWebSocketController?
    var id: UUID?
    weak var delegate: DTHomeWebSocketControllerDelegate?
    weak var newDocDelegate: DTNewDocumentWebSocketControllerDelegate?
    private let decoder = JSONDecoder()

    var handledMessageType = DTMessageType.home

    func handleMessage(_ data: Data) {
        do {
            let message = try decoder.decode(DTHomeMessage.self, from: data)
            switch message.subtype {
            case .createRoom:
                try self.handleCreateRoom(data)
            case .joinViaInvite:
                try self.handleJoinRoomFromInvite(data)
            case .accessibleRooms:
                try self.handleAccessibleRooms(data)
            }
        } catch {
            DTLogger.error { error.localizedDescription }
        }
    }

    func handleCreateRoom(_ data: Data) throws {
        let message = try decoder.decode(DTCreateRoomMessage.self, from: data)
        guard let createdRoom = message.room else {
            fatalError("Backend sent nil created room")
        }
        newDocDelegate?.didCreateRoom(newRoom: createdRoom)
    }

    func handleAccessibleRooms(_ data: Data) throws {
        let message = try decoder.decode(DTAccessibleRoomMessage.self, from: data)
        guard let newRooms = message.rooms else {
            fatalError("Backend sent nil rooms")
        }
        delegate?.didGetAccessibleRooms(newRooms: newRooms)
    }

    func handleJoinRoomFromInvite(_ data: Data) throws {
        let message = try decoder.decode(DTJoinRoomViaInviteMessage.self, from: data)
        guard let joinedRoom = message.joinedRoom else {
            newDocDelegate?.didFailToJoinRoom()
            return
        }
        newDocDelegate?.didJoinRoomFromInvite(joinedRoom: joinedRoom)
    }

    func getAccessibleRooms() {
        guard let id = id,
              let userId = DTAuth.user?.uid else {
            fatalError("Cannot get socket UUID or userId")
        }
        let message = DTAccessibleRoomMessage(id: id, userId: userId)
        send(message)
    }

    func createRoom(newRoom: DTAdaptedRoom.CreateRequest) {
        guard let id = id else {
            fatalError("Cannot get socket UUID")
        }
        let message = DTCreateRoomMessage(id: id, ownerId: newRoom.ownerId, name: newRoom.name)
        send(message)
    }

    func joinRoomFromInvite(inviteCode: String) {
        guard let id = id,
              let userId = DTAuth.user?.uid else {
            fatalError("Cannot get socket UUID or userId")
        }

        let message = DTJoinRoomViaInviteMessage(id: id, userId: userId, inviteCode: inviteCode)
        send(message)
    }

}
