import Foundation
import DTSharedLibrary

protocol DTWebSocketSubController {
    var handledMessageType: DTMessageType { get }
    func handleMessage(_ data: Data)
}

protocol DTSendableWebSocketSubController: DTWebSocketSubController {
    var parentController: DTWebSocketController? { get set }
    var id: UUID? { get set }
    func send(_ data: Data)
    func send(_ data: Data, callback: @escaping () -> Void)
}

extension DTSendableWebSocketSubController {
    func send<T>(_ message: T) where T: Codable {
        send(message, callback: {})
    }

    func send<T>(_ message: T, callback: @escaping () -> Void) where T: Codable {
        guard let parentController = self.parentController else {
            fatalError("Unable to get parent WS controller")
        }
        parentController.sendViaPipeline(message, callback: callback)
    }
}

final class DTWebSocketController {
    var id: UUID?
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
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

    private func connect() {
        self.setupWebsocket()
        self.registerSubcontroller(self)
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

    private func onData(_ data: Data) {
        do {
            let message = try decoder.decode(DTMessage.self, from: data)
            guard let wsSubcontroller = wsSubcontrollers[message.type] else {
                fatalError("No registered WS subcontroller for message type \(message.type)")
            }
            wsSubcontroller.handleMessage(data)
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    private func runSendDataMiddlewares(_ data: Data) -> Data {
        // Dummy method for client send middlewares
        data
    }

    func sendViaPipeline<T>(_ message: T) where T: Codable {
        sendViaPipeline(message, callback: {})
    }

    func sendViaPipeline<T>(_ message: T, callback: @escaping () -> Void) where T: Codable {
        do {
            let rawData = try encoder.encode(message)
            let encodedData = runSendDataMiddlewares(rawData)
            self.socket.send(.data(encodedData)) { err in
                if err != nil {
                    DTLogger.error { err.debugDescription }
                } else {
                    callback()
                }
            }
        } catch {
            DTLogger.error { error.localizedDescription }
        }
    }

    func registerSubcontroller(_ subcontroller: DTWebSocketSubController) {
        wsSubcontrollers[subcontroller.handledMessageType] = subcontroller
    }

    func registerSubcontroller(_ subcontroller: DTSendableWebSocketSubController) {
        registerSubcontroller(subcontroller as DTWebSocketSubController)

        // Inject DTWebSocketController into sendable subcontroller so that send operations
        // can run through DTWebSocketController's send pipeline
        var sc = subcontroller
        sc.parentController = self
        sc.id = self.id
    }

    func removeSubcontroller(_ subcontroller: DTWebSocketSubController) {
        wsSubcontrollers[subcontroller.handledMessageType] = nil
    }
}
