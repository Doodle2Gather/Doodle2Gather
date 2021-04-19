import DTSharedLibrary
import Foundation

protocol DTHomeWebSocketControllerDelegate: AnyObject {
    func didGetAccessibleRooms(newRooms: [DTAdaptedRoom])
}

final class DTHomeWebSocketController: DTSendableWebSocketSubController {
    var parentController: DTWebSocketController?
    var id: UUID?
    weak var delegate: DTHomeWebSocketControllerDelegate?
    private let decoder = JSONDecoder()

    var handledMessageType = DTMessageType.home

    func handleMessage(_ data: Data) {
        do {
            let message = try decoder.decode(DTHomeMessage.self, from: data)
            switch message.subtype {
            case .createRoom:
                break
            case .joinViaInvite:
                break
            case .accessibleRooms:
                try self.handleAccessibleRooms(data)
            }
        } catch {
            DTLogger.error { error.localizedDescription }
        }
    }

    func handleAccessibleRooms(_ data: Data) throws {
        let message = try decoder.decode(DTAccessibleRoomMessage.self, from: data)
        guard let newRooms = message.rooms else {
            fatalError("Backend sent nil rooms")
        }
        delegate?.didGetAccessibleRooms(newRooms: newRooms)
    }

    func getAccessibleRooms() {
        guard let id = id,
              let userId = DTAuth.user?.uid else {
            fatalError("Cannot get socket UUID or userId")
        }
        let message = DTAccessibleRoomMessage(id: id, userId: userId)
        send(message)
    }
//
//    func sendRegisterMessage(userId: String, displayName: String, email: String, callback: @escaping () -> Void) {
//        guard let id = id else {
//            fatalError("Cannot get socket UUID")
//        }
//        let message = DTRegisterMessage(id: id, uid: userId, displayName: displayName, email: email)
//        send(message, callback: callback)
//    }
//
//    func sendLoginMessage(userId: String, displayName: String, email: String, callback: @escaping () -> Void) {
//        guard let id = id else {
//            fatalError("Cannot get socket UUID")
//        }
//        let message = DTLoginMessage(id: id, uid: userId, displayName: displayName, email: email)
//        send(message, callback: callback)
//    }
}
