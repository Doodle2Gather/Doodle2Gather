import Fluent
import Vapor

final class PersistedDTStroke: Model, Content {
    static let schema = "strokes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    @Parent(key: "doodle_id")
    var doodle: PersistedDTDoodle

    @Field(key: "stroke_data")
    var strokeData: Data

    @Field(key: "created_by")
    var createdBy: UUID

    init() { }

    init(strokeData: Data, roomId: PersistedDTRoom.IDValue,
         doodleId: PersistedDTDoodle.IDValue, createdBy: UUID, id: UUID? = nil) {
        self.$room.id = roomId
        self.$doodle.id = doodleId
        self.strokeData = strokeData
        self.createdBy = createdBy
        self.id = id
    }
}
