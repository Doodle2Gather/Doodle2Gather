import Fluent
import Vapor

final class PersistedDTRoom: Model, Content {
    static let schema = "rooms"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "createdBy")
    var createdBy: PersistedDTUser

    @Children(for: \.$room)
    var doodles: [PersistedDTDoodle]

    init() { }

    init(name: String, createdBy: PersistedDTUser.IDValue) {
        self.id = UUID()
        self.name = name
        self.$createdBy.id = createdBy
    }
}
