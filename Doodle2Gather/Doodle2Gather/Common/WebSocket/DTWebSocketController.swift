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
                print(error)
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
            let uncompressedData = try Data(referencing: NSData(data: data).decompressed(using: .lzfse))
            let decodedData = try decoder.decode(DoodleActionMessageData.self, from: uncompressedData)
            switch decodedData.type {
            case .handshake:
                print("Shook the hand")
                let message = try decoder.decode(DoodleActionHandShake.self, from: data)
                self.id = message.id
            case .feedback:
                try self.handleNewActionFeedback(data)
            default:
                break
            }
        } catch {
            print(error)
        }
    }

    func handleNewActionFeedback(_ data: Data) throws {
        let feedback = try decoder.decode(NewDoodleActionFeedback.self, from: data)
        DispatchQueue.main.async {
            if feedback.success, feedback.id != nil {
                let action = DTAction(strokesAdded: feedback.strokesAdded, strokesRemoved: feedback.strokesRemoved)
                self.delegate?.dispatchAction(action)
            } else {
                print(feedback.message)
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
        print("adding action")
        let message = NewDoodleActionMessage(
            id: id, strokesAdded: action.strokesAdded, strokesRemoved: action.strokesRemoved)
        do {
            let data = try encoder.encode(message)
            let compressedData: Data
            do {
                compressedData = try Data(referencing: NSData(data: data).compressed(using: .lzfse))
            } catch {
                print(error.localizedDescription)
                return
            }
            self.socket.send(.data(compressedData)) { err in
                if err != nil {
                    print(err.debugDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}
