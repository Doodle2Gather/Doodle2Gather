import Fluent
import Vapor

final class PersistedDTUser: Model, Content {
    static let schema = "users"

    @ID(custom: .id)
    var id: String?

    @Field(key: "display_name")
    var displayName: String

    @Field(key: "email")
    var email: String

    @Children(for: \.$createdBy)
    var createdRooms: [PersistedDTRoom]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: String, displayName: String, email: String) {
        self.id = id
        self.displayName = displayName
        self.email = email
    }

    func update(copy: PersistedDTUser) {
        self.displayName = copy.displayName
        self.email = copy.email
     }
}
