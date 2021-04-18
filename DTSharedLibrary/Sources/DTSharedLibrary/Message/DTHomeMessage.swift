import Foundation

public struct DTHomeMessage: Codable {
    public let id: UUID
    public let subtype: DTHomeMessageType
}

public struct DTCreateRoomMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.createRoom
    public let id: UUID

    public let ownerId: String
    // nil for request message nad not nil for response from server
    public let room: DTAdaptedRoom?

    public init(id: UUID, ownerId: String, room: DTAdaptedRoom? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.room = room
    }
}

public struct DTJoinRoomViaInviteMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.joinViaInvite
    // public let id: UUID // I think this is meant for WS UUID, so I'll comment this out until we transition to full WS

    public let userId: String
    public let roomId: UUID?
    public let inviteCode: String?

    public init(// id: UUID,
        userId: String, roomId: UUID? = nil, inviteCode: String? = nil) {
        // self.id = id
        self.userId = userId
        self.roomId = roomId
        self.inviteCode = inviteCode
    }
}

public struct DTAccessibleRoomMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.accessibleRooms
    public let id: UUID

    public let userId: String
    // nil for request message nad not nil for response from server
    public let rooms: [DTAdaptedRoom]?

    public init(id: UUID, userId: String, rooms: [DTAdaptedRoom]? = nil) {
        self.id = id
        self.userId = userId
        self.rooms = rooms
    }
}
