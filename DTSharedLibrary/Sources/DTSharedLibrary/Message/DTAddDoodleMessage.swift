import Foundation

public struct DTAddDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.addDoodle

    public let wsId: UUID
    public let roomId: UUID

    public init(wsId: UUID, roomId: UUID) {
        self.wsId = wsId
        self.roomId = roomId
    }
}

public struct DTRemoveDoodleMessage: Codable {
    public var type = DTMessageType.room
    public var subtype = DTRoomMessageType.removeDoodle

    public let wsId: UUID
    public let roomId: UUID
    public let doodleId: UUID

    public init(wsId: UUID, roomId: UUID, doodleId: UUID) {
        self.wsId = wsId
        self.roomId = roomId
        self.doodleId = doodleId
    }
}

