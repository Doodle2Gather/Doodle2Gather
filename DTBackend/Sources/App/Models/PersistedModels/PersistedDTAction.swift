import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "action_type")
    var type: String

    @Field(key: "room_id")
    var roomId: UUID

    @Field(key: "strokes")
    var strokes: [Data]

    @Field(key: "created_by")
    var createdBy: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(type: DTActionType, strokes: [Data], roomId: UUID, createdBy: UUID, id: UUID? = nil) {
        self.type = type.rawValue
        self.roomId = roomId
        self.strokes = strokes
        self.createdBy = createdBy
        self.id = id
    }
}
