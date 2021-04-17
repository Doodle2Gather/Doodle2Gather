import Foundation

public struct DTHomeMessage: Codable {
    public let id: UUID
    public let subtype: DTHomeMessageType
}

public struct DTJoinRoomViaInviteMessage: Codable {
    public var type = DTMessageType.home
    public var subtype = DTHomeMessageType.joinViaInvite
    public let id: UUID
    
    public let userId: String
    public let roomId: UUID?
    public let inviteCode: String?

    public init(id: UUID, userId: String, roomId: UUID? = nil, inviteCode: String? = nil) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
        self.inviteCode = inviteCode
    }
}
