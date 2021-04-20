import Vapor
import Fluent
import DTSharedLibrary

class WSAuthController {
    let db: Database
    let logger = Logger(label: "WSAuthController")

    init(db: Database) {
        self.db = db
    }

    func onAuthMessage(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DTAuthMessage.self, from: data)
            logger.info("Received message: \(decodedData.subtype)")
            switch decodedData.subtype {
            case .login:
                let loginData = try decoder.decode(DTLoginMessage.self, from: data)
                self.handleLogin(ws, loginData)
            case .register:
                let registerData = try decoder.decode(DTRegisterMessage.self, from: data)
                self.handleRegister(ws, registerData)
            }
        } catch {
            logger.report(error: error)
        }
    }
}
