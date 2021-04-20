import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTEntityIndexPair: Model, Content {
    static let schema = "pairs"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "type")
    var type: DTEntityType

    @Field(key: "entity_data")
    var entity: Data

    @Field(key: "index")
    var index: Int

    @Field(key: "entity_id")
    var entityId: UUID

    @Field(key: "is_deleted")
    var isDeleted: Bool

    init() { }

    init(type: DTEntityType, entity: Data, index: Int, entityId: UUID,
         isDeleted: Bool = false, id: UUID? = nil) {
        self.type = type
        self.entity = entity
        self.index = index
        self.entityId = entityId
        self.isDeleted = isDeleted
        self.id = id
    }
}
