import Foundation

/// Represents the messages sent between client and server
/// when the client is inside a room/document
public struct DTRoomMessage: Codable {
    public let subtype: DTRoomMessageType
    public let id: UUID
    public let roomId: UUID
}

/// Represents the message sent when a user enters a room
public struct DTJoinRoomMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.joinRoom
    public let id: UUID
    public let userId: String
    public let roomId: UUID

    public init(id: UUID, userId: String, roomId: UUID) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
    }
}

/// Represents a message that contains information on all users who
/// have access to the room
public struct DTParticipantInfoMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.participantInfo
    public let id: UUID
    public let roomId: UUID

    public let users: [DTAdaptedUserAccesses]

    public init(id: UUID, roomId: UUID, users: [DTAdaptedUserAccesses]) {
        self.id = id
        self.roomId = roomId
        self.users = users
    }
}

/// Represents the message sent by a client to the server to initiate a new action
/// (i.e. to update the doodle copy on the server with a latest change)
public struct DTInitiateActionMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.initiateAction
    public let id: UUID
    public let userId: String
    public let roomId: UUID

    public let action: DTAdaptedAction

    public init(actionType: DTActionType, entities: [DTEntityIndexPair],
                id: UUID, userId: String, roomId: UUID, doodleId: UUID) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
        self.action = DTAdaptedAction(
            type: actionType, entities: entities,
            roomId: roomId, doodleId: doodleId, createdBy: userId)
    }
}

/// Represents the message that the server sent back to the client
/// that just initiated an action
public struct DTActionFeedbackMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.actionFeedback
    public let id: UUID
    public let roomId: UUID

    public let success: Bool
    public let message: String
    public let originalAction: DTAdaptedAction
    public let dispatchedAction: DTAdaptedAction?

    public init(id: UUID, roomId: UUID, success: Bool, message: String,
                originalAction: DTAdaptedAction, dispatchedAction: DTAdaptedAction?
    ) {
        self.id = id
        self.roomId = roomId
        self.success = success
        self.message = message
        self.originalAction = originalAction
        self.dispatchedAction = dispatchedAction
    }
}

/// Represents the message that the server dispatched to all peers
/// after receiving an action to update all peers with the latest change to a doodle
public struct DTDispatchActionMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.dispatchAction
    public let id: UUID
    public let roomId: UUID

    public let success: Bool
    public let message: String
    public let action: DTAdaptedAction

    public init(id: UUID, roomId: UUID,
                success: Bool, message: String, action: DTAdaptedAction) {
        self.id = id
        self.roomId = roomId
        self.success = success
        self.message = message
        self.action = action
    }
}

/// Represents the message that sent by a client to the server to
/// request a fetch of the latest state of a doodle
public struct DTRequestFetchMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.requestFetch
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
    }
}

/// Represents the message that sent by the server to a user which
/// contains the latest state of a doodle
public struct DTFetchDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.fetchDoodle
    public let id: UUID
    public let roomId: UUID

    public let success: Bool
    public let message: String
    public let doodles: [DTAdaptedDoodle]

    public init(id: UUID, roomId: UUID,
                success: Bool, message: String, doodles: [DTAdaptedDoodle]) {
        self.id = id
        self.roomId = roomId
        self.success = success
        self.message = message
        self.doodles = doodles
    }
}

/// Represents the message sent by a client to the server to
/// request the creation of a new doodle to an existing room/document
public struct DTRequestAddDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.requestAddDoodle
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
    }
}

/// Represents the message sent by the server to clients to create
/// a new doodle to an existing room/document
public struct DTAddDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.addDoodle
    public let id: UUID
    public let roomId: UUID

    public let newDoodle: DTAdaptedDoodle

    public init(id: UUID, roomId: UUID, newDoodle: DTAdaptedDoodle) {
        self.id = id
        self.roomId = roomId
        self.newDoodle = newDoodle
    }
}

/// Represents the message sent between the clients and the server
/// to remove an existing doodle from a room/document
public struct DTRemoveDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.removeDoodle

    public let id: UUID
    public let roomId: UUID
    public let doodleId: UUID

    public init(id: UUID, roomId: UUID, doodleId: UUID) {
        self.id = id
        self.roomId = roomId
        self.doodleId = doodleId
    }
}

/// Represents the message sent when a user leaves a room
public struct DTExitRoomMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.exitRoom
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
    }
}

/// Represents the message containing information on all users
/// who are currently inside a particular room
public struct DTRoomLiveStateMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.updateLiveState
    public var id = UUID()
    public var roomId: UUID
    public let usersInRoom: [DTAdaptedUser]

    public init(roomId: UUID, usersInRoom: [DTAdaptedUser]) {
        self.roomId = roomId
        self.usersInRoom = usersInRoom
    }
}

/// Represents the message containing information on the conference
/// state of all users who are currently inside a particular room
public struct DTUsersConferenceStateMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.usersConferenceState
    public var id = UUID()
    public var roomId: UUID
    public let conferenceState: [DTAdaptedUserConferenceState]

    public init(roomId: UUID, conferenceState: [DTAdaptedUserConferenceState]) {
        self.roomId = roomId
        self.conferenceState = conferenceState
    }
}

/// Represents the message sent to update users' conference state
public struct DTUpdateUserConferencingStateMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.updateConferenceState
    public var id: UUID
    public var roomId: UUID
    public var isVideoOn: Bool
    public var isAudioOn: Bool

    public init(id: UUID, roomId: UUID, isVideoOn: Bool, isAudioOn: Bool) {
        self.id = id
        self.roomId = roomId
        self.isVideoOn = isVideoOn
        self.isAudioOn = isAudioOn
    }
}

public struct DTSetUserPermissionsMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.setUserPermission
    public var id: UUID
    public var roomId: UUID
    public var userToSetId: String
    public let setCanEdit: Bool
    public let setCanVideoConference: Bool
    public let setCanChat: Bool

    public init(id: UUID, roomId: UUID, userToSetId: String,
                setCanEdit: Bool, setCanVideoConference: Bool, setCanChat: Bool) {
        self.id = id
        self.roomId = roomId
        self.userToSetId = userToSetId
        self.setCanEdit = setCanEdit
        self.setCanVideoConference = setCanVideoConference
        self.setCanChat = setCanChat
    }
}
