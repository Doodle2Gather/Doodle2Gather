import Foundation

/// General types of message sent between the clients and the server
public enum DTMessageType: String, Codable {
    case handshake, auth, home, room
}

/// Subtypes of `DTAuthMessage`
public enum DTAuthMessageType: String, Codable {

    case login, register

}

/// Subtypes of `DTHomeMessage`
public enum DTHomeMessageType: String, Codable {

    case createRoom, joinViaInvite, accessibleRooms

}

/// Subtypes of `DTRoomMessage`
public enum DTRoomMessageType: String, Codable {

    /// Message type(s) with regard to clients joining room
    case joinRoom

    /// Message type(s) with regards to client initiating new actions
    case initiateAction, actionFeedback, dispatchAction

    /// Message type(s) with regard to fetching of doodles when a client is out of sync with the server
    case requestFetch, fetchDoodle

    /// Message type(s) with regard to the adding and removing of doodle of a room
    case requestAddDoodle, addDoodle, removeDoodle

    /// Message type(s) with regard to the update of participant info / active user info of a room
    case participantInfo, updateLiveState, updateConferenceState, usersConferenceState

    /// Message type(s) with regard to the settings of user permission, which can only be sent by the owner of a room
    case setUserPermission

    /// Message type(s) with regard to room activites, e.g. room timer, etc.
    case setRoomTimer

    /// Message type with regard to client leaving room
    case exitRoom

}
