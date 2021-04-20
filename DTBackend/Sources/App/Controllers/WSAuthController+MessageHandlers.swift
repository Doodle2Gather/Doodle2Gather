import Vapor
import Fluent
import DTSharedLibrary

/// Handles all `DTAuthMessage` sent between the clients and the server
extension WSAuthController {

    func handleLogin(_ ws: WebSocket, _ message: DTLoginMessage) {
        let newUser = PersistedDTUser(id: message.uid, displayName: message.displayName, email: message.email)
        newUser.save(on: db).whenComplete { _ in
            self.logger.info("Logged in successfully: \(message.displayName)")
        }
    }

    func handleRegister(_ ws: WebSocket, _ message: DTRegisterMessage) {
        let newUser = PersistedDTUser(id: message.uid, displayName: message.displayName, email: message.email)
        newUser.save(on: db).whenComplete { _ in
            self.logger.info("Registered successfully: \(message.displayName)")
        }
    }
}
