import Foundation
import DTSharedLibrary

protocol DTWebSocketSubController {
    func handleMessage(_ data: Data)
}

final class DTWebSocketController {
    private var id: UUID?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var wsSubcontrollers = [DTMessageType: DTWebSocketSubController]()
    private let socket: URLSessionWebSocketTask

    init() {
        // change to localRoom for testing
        guard let wsEndpoint = URL(string: ApiEndpoints.WS) else {
            fatalError("Unable to parse WebSocket endpoint URL")
        }
        self.socket = URLSession(configuration: .default).webSocketTask(with: wsEndpoint)
        self.connect()
    }

    func connect() {
        self.setupWebsocket()
        self.listen()
        self.socket.resume()
    }

    private func setupWebsocket() {
        self.socket.maximumMessageSize = Int.max
    }

    private func listen() {
        // This callback is a one-time callback, and hence the closure has
        // to be re-registered everytime a message is received.
        self.socket.receive { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                DTLogger.error(error.localizedDescription)
                return
            case .success(let message):
                switch message {
                case .data(let data):
                    self.decodeReceivedData(data)
                case .string(let str):
                    guard let data = str.data(using: .utf8) else {
                        return
                    }
                    self.decodeReceivedData(data)
                @unknown default:
                    break
                }
            }
            self.listen()
        }
    }

    private func runReceiveDataMiddlewares(_ data: Data) -> Data {
        // Dummy method for client receive middlewares
        data
    }

    private func decodeReceivedData(_ data: Data) {
        let decodedData = self.runReceiveDataMiddlewares(data)
        self.onData(decodedData)
    }

    func onData(_ data: Data) {
        do {
            let message = try decoder.decode(DTMessage.self, from: data)
            switch message.type {
            case .handshake:
                DTLogger.event("Shook the hand")
                let handshake = try decoder.decode(DTHandshake.self, from: data)
                self.id = handshake.id
            case .auth, .home:
                break
            case .room:
                handleRoomMessages(data)
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    private func handleRoomMessages(_ data: Data) {
//        do {
//            let message = try decoder.decode(DTRoomMessage.self, from: data)
//            switch message.subtype {
//            case .actionFeedback:
//                try self.handleActionFeedback(data)
//            case .dispatchAction:
//                try self.handleDispatchedAction(data)
//            case .fetchDoodle:
//                try self.handleFetchDoodle(data)
//            case .addDoodle:
//                try self.handleAddDoodle(data)
//            case .removeDoodle:
//                try self.handleRemoveDoodle(data)
//            case .participantInfo:
//                try self.handleParticipantInfo(data)
//            default:
//                break
//            }
//        } catch {
//            DTLogger.error(error.localizedDescription)
//        }
    }
}
