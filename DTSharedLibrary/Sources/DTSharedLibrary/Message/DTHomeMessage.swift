import Foundation

/// Represents the messages sent between client and server
/// after the client has logged in and before the client joins a room
/// (aka when a client is the gallery view)
public struct DTHomeMessage: Codable {
    public let id: UUID
    public let subtype: DTHomeMessageType
}

/// Represents the message sent to create a new room/document
public struct DTCreateRoomMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.createRoom
    public let id: UUID

    public let ownerId: String
    public let name: String
    // nil for request message nad not nil for response from server
    public let room: DTAdaptedRoom?

    public init(id: UUID, ownerId: String, name: String, room: DTAdaptedRoom? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.room = room
    }
}

/// Represents the message sent to request access to an existing room through a invite code
public struct DTJoinRoomViaInviteMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.joinViaInvite
    public let id: UUID

    public let userId: String
    public let roomId: UUID?
    public let inviteCode: String?

    /// nil for request message and not nil for response from server
    public var joinedRoom: DTAdaptedRoom?

    public init(id: UUID,
                userId: String,
                roomId: UUID? = nil,
                inviteCode: String? = nil,
                joinedRoom: DTAdaptedRoom? = nil) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
        self.inviteCode = inviteCode
        self.joinedRoom = joinedRoom
    }
}

/// Represents the message sent to fetch all rooms that are accessible by the user
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
