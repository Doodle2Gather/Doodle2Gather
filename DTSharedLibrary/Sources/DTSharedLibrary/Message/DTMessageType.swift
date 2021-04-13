import Foundation

public enum DTMessageType: String, Codable {
    // Client to server types
    case joinRoom, initiateAction, clearDrawing, requestFetch
    // Server to client types
    case handshake, actionFeedback, dispatchAction, fetchDoodle

    case drawing
}
