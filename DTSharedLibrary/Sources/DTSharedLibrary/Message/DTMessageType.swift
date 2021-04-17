import Foundation

public enum DTMessageType: String, Codable {
    case auth, home, room
}

public enum DTAuthMessageType: String, Codable {
    case login, register
}

public enum DTHomeMessageType: String, Codable {
    case haha
}

public enum DTRoomMessageType: String, Codable {
    // Client to server types
    case joinRoom, initiateAction, clearDrawing, requestFetch, addDoodle, removeDoodle, exitRoom
    // Server to client types
    case handshake, actionFeedback, dispatchAction, fetchDoodle
}
