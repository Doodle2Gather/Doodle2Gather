//
//  WebSocketController.swift
//  Doodle2Gather
//
//  Created by eksinyue on 20/3/21.
//

import Foundation

struct AlertWrapper: Identifiable {
    let id = UUID()
}

final class WebSocketController: ObservableObject {
    @Published var actions: [UUID: WebSocketTypes.NewDoodleActionResponse]
    @Published var alertWrapper: AlertWrapper?

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        self.actions = [:]
        self.alertWrapper = nil

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

    func addAction(_ content: String) {
        guard let id = self.id else {
            return
        }
        let message = WebSocketTypes.NewDoodleActionMessage(id: id, content: content)
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

    func handle(_ data: Data) {
        do {
            let decodedData = try decoder.decode(WebSocketTypes.DoodleActionMessageData.self, from: data)
            switch decodedData.type {
            case .handshake:
                print("Shook the hand")
                let message = try decoder.decode(WebSocketTypes.DoodleActionHandShake.self, from: data)
                self.id = message.id
            case .response:
                try self.handleQuestionResponse(data)
            default:
                break
            }
        } catch {
            print(error)
        }
    }

    func handleQuestionResponse(_ data: Data) throws {
        // 1
        let response = try decoder.decode(WebSocketTypes.NewDoodleActionResponse.self, from: data)
        DispatchQueue.main.async {
            if response.success, let id = response.id {
                self.actions[id] = response
            } else {
                print(response.message)
            }
        }
    }
}
