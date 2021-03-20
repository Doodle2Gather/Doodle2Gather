import Foundation

enum DoodleActionMessageType: String, Codable {
    // Client to server types
    case newAction
    // Server to client types
    case handshake, response
}

struct DoodleActionMessageData: Codable {
    let type: DoodleActionMessageType
    let id: UUID
}

struct DoodleActionHandShake: Codable {
    var type = DoodleActionMessageType.handshake
    let id: UUID
}

struct NewDoodleActionMessage: Codable {
    let content: String
}

struct NewDoodleActionResponse: Codable {
    var type = DoodleActionMessageType.response
    let success: Bool
    let message: String
    let id: UUID?
    let content: String
    let createdAt: Date?
}
