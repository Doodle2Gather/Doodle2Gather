import Foundation

public enum DTMessageType: String, Codable {
    // Client to server types
    case newAction
    // Server to client types
    case handshake, actionFeedback, dispatchAction
}
