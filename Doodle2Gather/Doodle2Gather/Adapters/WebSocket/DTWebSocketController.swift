import Foundation
import DTSharedLibrary

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
        self.socket = session.webSocketTask(with: URL(string: ApiEndpoints.Room)!) // change to localRoom for testing
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
                try self.handleDispatchedAction(data)
            case .clearDrawing:
                try self.handleClearDrawing(data)
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
            if !feedback.success {
                DTLogger.error(feedback.message)
                return
            }
        }
    }

    func handleDispatchedAction(_ data: Data) throws {
        let dispatch = try decoder.decode(DTDispatchActionMessage.self, from: data)
        DispatchQueue.main.async {
            // TODO: refactor unhappy path to be at the top
            if dispatch.success {
                let action = DTNewAction(
                    action: dispatch.action
                )
                self.delegate?.dispatchAction(action)
            } else {
                DTLogger.error(dispatch.message)
            }
        }
    }

    func handleClearDrawing(_ data: Data) throws {
        // let action = try decoder.decode(DTClearDrawingMessage.self, from: data)
        DispatchQueue.main.async {
            // TODO: clearDrawing for roomId
            self.delegate?.clearDrawing()
        }
    }
}

// MARK: - SocketController

extension DTWebSocketController: SocketController {

    func addAction(_ action: DTNewAction) {
        guard let id = self.id else {
            return
        }
        DTLogger.info("Adding action")

        let message = DTInitiateActionMessage(
            actionType: action.type, strokes: action.strokes,
            id: id, roomId: action.roomId, doodleId: action.doodleId
        )
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

    func clearDrawing() {
        DTLogger.info("clear drawing")
        let message = DTClearDrawingMessage(
            id: id,
            roomId: UUID()) // TODO: change to roomId
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

    func refetchDoodles() {
        // TODO: XinYue please help!!
        // But this should call delegate?.loadDoodles(doodles)
    }

}
