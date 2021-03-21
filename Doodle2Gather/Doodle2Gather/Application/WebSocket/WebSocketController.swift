//
//  WebSocketController.swift
//  Doodle2Gather
//
//  Created by eksinyue on 20/3/21.
//

import Foundation

final class WebSocketController: ObservableObject {
    @Published var actions: [UUID: NewDoodleActionFeedback]

    private var canvasController: CanvasController

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(canvasController: CanvasController) {
        self.canvasController = canvasController

        self.actions = [:]
        self.session = URLSession(configuration: .default)
        self.connect()
    }

    func connect() {
        self.socket = session.webSocketTask(with: URL(string: "ws://localhost:8080/rooms/devRoom")!)
        self.actions = [:]
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
            let decodedData = try decoder.decode(DoodleActionMessageData.self, from: data)
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
            if feedback.success, let id = feedback.id {
                self.actions[id] = feedback
                let action = DTAction(strokesAdded: feedback.strokesAdded, strokesRemoved: feedback.strokesRemoved)
                self.canvasController.dispatch(action: action)
            } else {
                print(feedback.message)
            }
        }
    }

    func addAction(_ action: DTAction) {
        guard let id = self.id else {
            return
        }
        print("adding action")
        let message = NewDoodleActionMessage(
            id: id, strokesAdded: action.strokesAdded, strokesRemoved: action.strokesRemoved)
        do {
            let data = try encoder.encode(message)
            self.socket.send(.data(data)) { err in
                if err != nil {
                    print(err.debugDescription)
                }
            }
        } catch {
            print(error)
        }
    }
}
