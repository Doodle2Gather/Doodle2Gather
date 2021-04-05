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
}
