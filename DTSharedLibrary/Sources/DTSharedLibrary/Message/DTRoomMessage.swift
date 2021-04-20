import Foundation

public struct DTRoomMessage: Codable {
    public let subtype: DTRoomMessageType
    public let id: UUID
    public let roomId: UUID
}

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

public struct DTClearDrawingMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.clearDrawing
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
    }
}

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

public struct DTUsersVideoConferenceStateMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.usersConferenceState
    public var id = UUID()
    public var roomId: UUID
    public let videoConferenceState: [DTAdaptedUserVideoConferenceState]

    public init(roomId: UUID, videoConferenceState: [DTAdaptedUserVideoConferenceState]) {
        self.roomId = roomId
        self.videoConferenceState = videoConferenceState
    }
}

public struct DTUpdateUserVideoStateMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.updateVideoState
    public var id: UUID
    public var roomId: UUID
    public var isVideoOn: Bool

    public init(id: UUID, roomId: UUID, isVideoOn: Bool) {
        self.id = id
        self.roomId = roomId
        self.isVideoOn = isVideoOn
    }
}
