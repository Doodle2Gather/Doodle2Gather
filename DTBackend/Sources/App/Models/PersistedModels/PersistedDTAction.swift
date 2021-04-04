import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "room_id")
    var roomId: UUID

    @Field(key: "strokes_added")
    var strokesAdded: Set<Data>

    @Field(key: "strokes_removed")
    var strokesRemoved: Set<Data>

    @Field(key: "created_by")
    var createdBy: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>, roomId: UUID, createdBy: UUID, id: UUID? = nil) {
        self.roomId = roomId
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.createdBy = createdBy
        self.id = id
    }
}
