import Foundation

final class DTWebSocketController {

    weak var delegate: SocketControllerDelegate?

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        self.session = URLSession(configuration: .default)
        self.connect()
    }

    func connect() {
        self.socket = session.webSocketTask(with: URL(string: ApiEndpoints.Room)!)
        self.socket.maximumMessageSize = Int.max
        self.listen()
        self.socket.resume()
    }

    func listen() {
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
                    self.handle(data)
                case .string(let str):
                    guard let data = str.data(using: .utf8) else {
                        return
                    }
                    self.handle(data)
                @unknown default:
                    break
                }
            }
            self.listen()
        }
    }

    func handle(_ data: Data) {
        do {
            let decodedData = try decoder.decode(DoodleActionMessageData.self, from: data)
            switch decodedData.type {
            case .handshake:
                DTLogger.event("Shook the hand")
                let message = try decoder.decode(DoodleActionHandShake.self, from: data)
                self.id = message.id
            case .feedback:
                try self.handleNewActionFeedback(data)
            default:
                break
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    func handleNewActionFeedback(_ data: Data) throws {
        let feedback = try decoder.decode(NewDoodleActionFeedback.self, from: data)
        DispatchQueue.main.async {
            // TODO: refactor unhappy path to be at the top
            if feedback.success, feedback.id != nil {
                let action = DTAction(strokesAdded: feedback.strokesAdded, strokesRemoved: feedback.strokesRemoved)
                self.delegate?.dispatchAction(action)
            } else {
                DTLogger.error(feedback.message)
            }
        }
    }

}

// MARK: - SocketController

extension DTWebSocketController: SocketController {

    func addAction(_ action: DTAction) {
        guard let id = self.id else {
            return
        }
        DTLogger.info("adding action")
        let message = NewDoodleActionMessage(
            id: id, strokesAdded: action.strokesAdded, strokesRemoved: action.strokesRemoved)
        do {
            let data = try encoder.encode(message)
            self.socket.send(.data(data)) { err in
                if err != nil {
                    DTLogger.error(err.debugDescription)
                }
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

}
