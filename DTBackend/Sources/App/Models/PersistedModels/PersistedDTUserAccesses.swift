import Fluent
import Foundation

final class PersistedDTUserAccesses: Model {
    static let schema = "users+rooms"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: PersistedDTUser

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    init() { }

    init(user: PersistedDTUser, room: PersistedDTRoom) throws {
        self.id = UUID()
        self.$user.id = try user.requireID()
        self.$room.id = try room.requireID()
    }
}
