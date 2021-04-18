import Foundation

public enum DTMessageType: String, Codable {
    case handshake, auth, home, room
}

public enum DTAuthMessageType: String, Codable {
    case login, register
}

public enum DTHomeMessageType: String, Codable {
    case joinViaInvite
}

public enum DTRoomMessageType: String, Codable {
    // Client to server types
    case joinRoom, initiateAction, clearDrawing, requestFetch, requestAddDoodle, exitRoom
    // Server to client types
    case actionFeedback, dispatchAction, fetchDoodle, participantInfo, addDoodle, removeDoodle
}
