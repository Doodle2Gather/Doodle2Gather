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

public struct DTInitiateActionMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.initiateAction
    public let id: UUID
    public let roomId: UUID

    public let action: DTAdaptedAction

    public init(actionType: DTActionType, strokes: [DTStrokeIndexPair],
                id: UUID, roomId: UUID, doodleId: UUID) {
        self.id = id
        self.roomId = roomId
        self.action = DTAdaptedAction(
            type: actionType, strokes: strokes,
            roomId: roomId, doodleId: doodleId, createdBy: id)
    }
}

public struct DTActionFeedbackMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.actionFeedback
    public let id: UUID
    public let roomId: UUID
    
    public let success: Bool
    public let message: String
    public let orginalAction: DTAdaptedAction
    public let dispatchedAction: DTAdaptedAction?

    public init(id: UUID, roomId: UUID, success: Bool, message: String,
                orginalAction: DTAdaptedAction, dispatchedAction: DTAdaptedAction?
    ) {
        self.id = id
        self.roomId = roomId
        self.success = success
        self.message = message
        self.orginalAction = orginalAction
        self.dispatchedAction = dispatchedAction
    }
}

public struct DTDispatchActionMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.actionFeedback
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

public struct DTAddDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.addDoodle
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
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

