import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTEntity: Model, Content {
    static let schema = "doodle_entities"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "type")
    var type: DTEntityType

    @Field(key: "room_id")
    var roomId: UUID // stores roomId here so that we dont need to query db when converting it to adapted model

    @Parent(key: "doodle_id")
    var doodle: PersistedDTDoodle

    @Field(key: "entity_id")
    var entityId: UUID

    @Field(key: "entity_data")
    var entityData: Data

    @Field(key: "is_deleted")
    var isDeleted: Bool

    @Field(key: "created_by")
    var createdBy: String

    init() { }

    init(type: DTEntityType, entityData: Data, entityId: UUID, roomId: UUID, doodleId: PersistedDTDoodle.IDValue,
         createdBy: String, isDeleted: Bool = false, id: UUID? = nil) {
        self.roomId = roomId
        self.$doodle.id = doodleId
        self.entityId = entityId
        self.entityData = entityData
        self.createdBy = createdBy
        self.isDeleted = isDeleted
        self.id = id
    }
}
