import Fluent
import Vapor

final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "room_id")
    var roomId: UUID

    @Field(key: "strokes_added")
    var strokesAdded: Data

    @Field(key: "strokes_removed")
    var strokesRemoved: Data

    @Field(key: "created_by")
    var createdBy: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(roomId: UUID, strokesAdded: Data, strokesRemoved: Data, createdBy: UUID, id: UUID? = nil) {
        self.roomId = roomId
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.createdBy = createdBy
        self.id = id
    }
}
