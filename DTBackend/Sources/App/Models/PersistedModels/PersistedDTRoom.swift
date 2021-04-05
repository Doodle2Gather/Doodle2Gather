import Fluent
import Vapor

final class PersistedDTRoom: Model, Content {
    static let schema = "rooms"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "id")
    var createdBy: PersistedDTUser

    @Children(for: \.$room)
    var doodles: [PersistedDTDoodle]

    init() { }

    init(name: String, id: UUID? = nil) {
        self.id = id
        self.name = name
    }

}
