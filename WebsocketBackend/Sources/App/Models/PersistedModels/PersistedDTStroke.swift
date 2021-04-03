import Fluent
import Vapor

final class PersistedDTStroke: Model, Content {
    static let schema = "strokes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "room_id")
    var roomId: UUID

    @Field(key: "stroke_data")
    var strokeData: Data

    @Field(key: "created_by")
    var createdBy: UUID

    init() { }

    init(roomId: UUID, strokeData: Data, createdBy: UUID, id: UUID? = nil) {
        self.roomId = roomId
        self.strokeData = strokeData
        self.createdBy = createdBy
        self.id = id
    }
}
