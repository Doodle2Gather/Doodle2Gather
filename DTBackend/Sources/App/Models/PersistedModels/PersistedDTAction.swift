import Fluent
import Vapor
import DTSharedLibrary

/// persisted model and schema which represents `DTAdaptedAction` and `DTAction`
final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "action_type")
    var type: String

    @Field(key: "room_id")
    var roomId: UUID // stores roomId here so that we dont need to query db when converting it to adapted model

    @Parent(key: "doodle_id")
    var doodle: PersistedDTDoodle

    @Field(key: "entities")
    var entities: [PersistedDTEntityIndexPair]

    @Field(key: "created_by")
    var createdBy: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(type: DTActionType, entities: [PersistedDTEntityIndexPair], roomId: UUID,
         doodleId: PersistedDTDoodle.IDValue, createdBy: String, id: UUID? = nil) {
        self.type = type.rawValue
        self.roomId = roomId
        self.$doodle.id = doodleId
        self.entities = entities
        self.createdBy = createdBy
        self.id = id
    }
}
