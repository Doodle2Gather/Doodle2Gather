import DTSharedLibrary
import Foundation

final class DTAuthWebSocketController: DTSendableWebSocketSubController {
    var parentController: DTWebSocketController?
    var id: UUID?

    var handledMessageType = DTMessageType.auth

    func handleMessage(_ data: Data) {
        // No responses for auth at the moment
        //        do {
        //        } catch {
        //            DTLogger.error { error.localizedDescription }
        //        }
    }

    func sendRegisterMessage(userId: String,
                             displayName: String,
                             email: String,
                             successCallback: @escaping () -> Void,
                             failureCallback: ((String) -> Void)?) {
        guard let id = id else {
            if let callback = failureCallback {
                callback("Could not get UUID of socket.")
            }
            return
        }
        let message = DTRegisterMessage(id: id,
                                        uid: userId,
                                        displayName: displayName,
                                        email: email)
        send(message, callback: successCallback)
    }

    func sendLoginMessage(userId: String,
                          displayName: String,
                          email: String,
                          successCallback: @escaping () -> Void,
                          failureCallback: ((String) -> Void)?) {
        guard let id = id else {
            if let callback = failureCallback {
                callback("Could not get UUID of socket.")
            }
            return
        }
        let message = DTLoginMessage(id: id, uid: userId, displayName: displayName, email: email)
        send(message, callback: successCallback)
    }
}
