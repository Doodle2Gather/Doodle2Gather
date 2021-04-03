import Foundation
import DoodlingAdaptedLibrary

final class DTWebSocketController {

    weak var delegate: SocketControllerDelegate?

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    /// Keeps check the number of messages received between the device initiates a new action and
    /// it receives the feedback message of that action from the server
    private static var potentialConflictMessageCount = 0

    init() {
        self.session = URLSession(configuration: .default)
        self.connect()
    }

    func connect() {
        self.socket = session.webSocketTask(with: URL(string: ApiEndpoints.localRoom)!)
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
            let decodedData = try decoder.decode(DTMessage.self, from: data)
            switch decodedData.type {
            case .handshake:
                DTLogger.event("Shook the hand")
                let message = try decoder.decode(DTHandshake.self, from: data)
                self.id = message.id
            case .actionFeedback:
                try self.handleActionFeedback(data)
            case .dispatchAction:
                DTWebSocketController.potentialConflictMessageCount += 1
                try self.handleDispatchedAction(data)
            default:
                break
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    func handleActionFeedback(_ data: Data) throws {
        // TODO: yet to be tested.
        let feedback = try decoder.decode(DTActionFeedbackMessage.self, from: data)
        DispatchQueue.main.async {
            if !feedback.success || feedback.id == nil {
                DTLogger.error(feedback.message)
                return
            }

            if feedback.isActionDenied, let revertAction = feedback.undoAction {
                let action = DTAction(
                    action: revertAction
                )
                let histories = feedback.actionHistories.map {
                    DTAction(action: $0)
                }.prefix(DTWebSocketController.potentialConflictMessageCount)
                self.delegate?.handleConflict(action, histories: Array(histories))
            }
        }
    }

    func handleDispatchedAction(_ data: Data) throws {
        let dispatch = try decoder.decode(DTDispatchActionMessage.self, from: data)
        DispatchQueue.main.async {
            // TODO: refactor unhappy path to be at the top
            if dispatch.success, dispatch.id != nil {
                let action = DTAction(
                    action: dispatch.action
                )
                self.delegate?.dispatchAction(action)
            } else {
                DTLogger.error(dispatch.message)
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
        let message = DTInitiateActionMessage(
            strokesAdded: action.strokesAdded,
            strokesRemoved: action.strokesRemoved,
            id: id,
            roomId: UUID())
        do {
            DTWebSocketController.potentialConflictMessageCount = 0
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
