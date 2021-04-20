import Fluent
import Vapor

/// persisted model and schema which represents `DTAdaptedRoom`
final class PersistedDTRoom: Model, Content {
    static let schema = "rooms"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "invite_code")
    var inviteCode: String

    @Parent(key: "created_by")
    var createdBy: PersistedDTUser

    @Siblings(through: PersistedDTUserAccesses.self, from: \.$room, to: \.$user)
    var accessibleBy: [PersistedDTUser]

    @Children(for: \.$room)
    var doodles: [PersistedDTDoodle]

    init() { }

    init(name: String, createdBy: PersistedDTUser.IDValue) {
        self.id = UUID()
        self.name = name
        self.inviteCode = generateInviteCode()
        self.$createdBy.id = createdBy
    }

    private func generateInviteCode() -> String {
        let code = Int.random(in: 0..<1_000_000)
        return String(format: "%06d", code)
    }

    func getChildren() -> [PersistedDTDoodle] {
        self.doodles
    }
}
