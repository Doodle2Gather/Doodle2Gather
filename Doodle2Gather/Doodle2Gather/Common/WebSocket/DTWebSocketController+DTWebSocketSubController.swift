import DTSharedLibrary
import Foundation

extension DTWebSocketController: DTWebSocketSubController {
    static let _handledMessageType = DTMessageType.handshake

    var handledMessageType: DTMessageType {
        DTWebSocketController._handledMessageType
    }

    func handleMessage(_ data: Data) {
        do {
         try handleHandshake(data)
        } catch {
            DTLogger.error { error.localizedDescription }
        }
    }

    private func handleHandshake(_ data: Data) throws {
        let handshake = try decoder.decode(DTHandshake.self, from: data)
        self.id = handshake.id
        DTLogger.event { "Established WS handshake. My socket UUID: \(handshake.id.uuidString)" }
    }
}
