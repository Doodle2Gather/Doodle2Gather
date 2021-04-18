import Foundation

public struct DTAdaptedUserAccesses: Codable {
    public let userId: String
    public let displayName: String
    public let isOwner: Bool

    // Permissions
    public let canEdit: Bool
    public let canVideoConference: Bool
    public let canChat: Bool

    public init(userId: String, displayName: String, isOwner: Bool,
                canEdit: Bool, canVideoConference: Bool, canChat: Bool) {
        self.userId = userId
        self.displayName = displayName
        self.isOwner = isOwner
        self.canEdit = canEdit
        self.canVideoConference = canVideoConference
        self.canChat = canChat
    }
}
