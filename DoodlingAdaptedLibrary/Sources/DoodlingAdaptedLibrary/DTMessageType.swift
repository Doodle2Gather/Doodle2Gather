import Foundation

enum DoodleActionMessageType: String, Codable {
    // Client to server types
    case newAction
    // Server to client types
    case handshake, feedback
}
