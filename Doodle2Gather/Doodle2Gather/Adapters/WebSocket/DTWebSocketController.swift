import Foundation
import DTSharedLibrary

final class DTWebSocketController {

    weak var delegate: SocketControllerDelegate?

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    var roomId: UUID?

    init() {
        self.session = URLSession(configuration: .default)
        self.connect()
    }

    func connect() {
        guard let url = URL(string: ApiEndpoints.localWS) else {
            return
        }
        self.socket = session.webSocketTask(with: url) // change to localRoom for testing
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
            let message = try decoder.decode(DTMessage.self, from: data)
            switch message.type {
            case .handshake:
                DTLogger.event("Shook the hand")
                let handshake = try decoder.decode(DTHandshake.self, from: data)
                self.id = handshake.id
                self.joinRoom(roomId: roomId!)
            case .auth, .home:
                break
            case .room:
                handleRoomMessages(data)
            default:
                break
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    private func handleRoomMessages(_ data: Data) {
        do {
            let message = try decoder.decode(DTRoomMessage.self, from: data)
            switch message.subtype {
            case .actionFeedback:
                try self.handleActionFeedback(data)
            case .dispatchAction:
                try self.handleDispatchedAction(data)
            case .fetchDoodle:
                try self.handleFetchDoodle(data)
            case .participantInfo:
                try self.handleParticipantInfo(data)
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
                let action = DTAction(
                    action: dispatch.action
                )
                self.delegate?.dispatchAction(action)
            } else {
                DTLogger.error(dispatch.message)
            }
        }
    }

    func handleFetchDoodle(_ data: Data) throws {
        let fetch = try decoder.decode(DTFetchDoodleMessage.self, from: data)
        DispatchQueue.main.async {
            self.delegate?.loadDoodles(fetch.doodles)
        }
    }

    func handleParticipantInfo(_ data: Data) throws {
        let fetch = try decoder.decode(DTParticipantInfoMessage.self, from: data)
        // TODO
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

    func joinRoom(roomId: UUID) {
        guard let id = self.id else {
            return
        }
        DTLogger.info("Joining room")

        let message = DTJoinRoomMessage(id: id, userId: DTAuth.user!.uid, roomId: roomId)
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

    func addAction(_ action: DTAction) {
        guard let id = self.id else {
            return
        }
        DTLogger.info("Adding action")

        let message = DTInitiateActionMessage(
            actionType: action.type, strokes: action.strokes,
            id: id, roomId: action.roomId, doodleId: action.doodleId
        )
        print(action.roomId)
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
        // Send a request to backend to send back a DTFetchDoodleMessage
        guard let id = self.id else {
            return
        }
        DTLogger.info("Request fetching doodles.")

        let message = DTRequestFetchMessage(id: id, roomId: roomId!)
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

    func disconnect() {
        DTLogger.info("Leaving room. Disconnecting ...")
//        let message = DTDisconnect(id: id)
//        do {
//            let data = try encoder.encode(message)
//            self.socket.send(.data(data)) { err in
//                if err != nil {
//                    DTLogger.error(err.debugDescription)
//                }
//            }
//        } catch {
//            DTLogger.error(error.localizedDescription)
//        }
//        self.socket.cancel(with: .goingAway, reason: nil)
    }
}
