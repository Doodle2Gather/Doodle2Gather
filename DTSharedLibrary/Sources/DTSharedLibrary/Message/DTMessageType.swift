import Foundation

public enum DTMessageType: String, Codable {
    // Client to server types
    case initiateAction, clearDrawing
    // Server to client types
    case handshake, actionFeedback, dispatchAction, fetchDoodle

    case drawing
}
