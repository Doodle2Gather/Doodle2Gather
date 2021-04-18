import Vapor
import Fluent
import Foundation

final class PersistedDTUserAccesses: Model, Content {
    static let schema = "users+rooms"
    static let CAN_EDIT_BY_DEFAULT = true
    static let CAN_VIDEO_CONFERENCE_BY_DEFAULT = true
    static let CAN_CHAT_BY_DEFAULT = true

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: PersistedDTUser

    @Parent(key: "room_id")
    var room: PersistedDTRoom
    
    @Field(key: "is_owner")
    var isOwner: Bool
    
    @Field(key: "can_edit")
    var canEdit: Bool
    
    @Field(key: "can_video_conference")
    var canVideoConference: Bool
    
    @Field(key: "can_chat")
    var canChat: Bool

    init() { }

    init(user: PersistedDTUser, room: PersistedDTRoom,
         isOwner: Bool = false,
         canEdit: Bool = CAN_EDIT_BY_DEFAULT,
         canVideoConference: Bool = CAN_VIDEO_CONFERENCE_BY_DEFAULT,
         canChat: Bool = CAN_CHAT_BY_DEFAULT
    ) throws {
        self.id = UUID()
        self.$user.id = try user.requireID()
        self.$room.id = try room.requireID()
        self.isOwner = isOwner
        self.canEdit = canEdit
        self.canVideoConference = canVideoConference
        self.canChat = canChat
    }
}
