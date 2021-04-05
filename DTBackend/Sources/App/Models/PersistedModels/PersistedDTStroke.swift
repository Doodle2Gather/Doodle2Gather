import Fluent
import Vapor

final class PersistedDTStroke: Model, Content {
    static let schema = "strokes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "room_id")
    var roomId: UUID // stores roomId here so that we dont need to query db when converting it to adapted model

    @Parent(key: "doodle_id")
    var doodle: PersistedDTDoodle

    @Field(key: "stroke_data")
    var strokeData: Data

    @Field(key: "created_by")
    var createdBy: UUID

    init() { }

    init(strokeData: Data, roomId: UUID,
         doodleId: PersistedDTDoodle.IDValue, createdBy: UUID, id: UUID? = nil) {
        self.roomId = roomId
        self.$doodle.id = doodleId
        self.strokeData = strokeData
        self.createdBy = createdBy
        self.id = id
    }
}
