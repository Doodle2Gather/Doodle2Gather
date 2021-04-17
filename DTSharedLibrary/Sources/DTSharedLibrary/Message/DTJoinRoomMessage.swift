import Foundation

public struct DTJoinRoomMessage: Codable {
    public var type = DTMessageType.joinRoom

    public let userId: String
    public let roomId: UUID?
    public let inviteCode: String?

    public init(userId: String, roomId: UUID? = nil, inviteCode: String? = nil) {
        self.userId = userId
        self.roomId = roomId
        self.inviteCode = inviteCode
    }
}
