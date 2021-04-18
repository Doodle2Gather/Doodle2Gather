import Foundation

public struct DTAdaptedUserAccesses: Codable {
    public let user: DTAdaptedUser
    public let roomId: UUID
    public let isOwner: Bool

    // Permissions
    public let canEdit: Bool
    public let canVideoConference: Bool
    public let canChat: Bool

    public init(user: DTAdaptedUser, roomId: UUID, isOwner: Bool,
                canEdit: Bool, canVideoConference: Bool, canChat: Bool) {
        self.user = user
        self.roomId = roomId
        self.isOwner = isOwner
        self.canEdit = canEdit
        self.canVideoConference = canVideoConference
        self.canChat = canChat
    }
}
