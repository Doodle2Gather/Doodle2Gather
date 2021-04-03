import Foundation

public enum DTMessageType: String, Codable {
    // Client to server types
    case initiateAction
    // Server to client types
    case handshake, actionFeedback, dispatchAction
    
    case drawing
}

public enum DTActionType: String, Codable {
    case add, remove, undo, redo
}
