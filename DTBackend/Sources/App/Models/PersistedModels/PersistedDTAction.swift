import Fluent
import Vapor
import DTSharedLibrary

final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "action_type")
    var type: String

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    @Parent(key: "doodle_id")
    var doodle: PersistedDTDoodle

    @Field(key: "strokes")
    var strokes: [PersistedDTStrokeIndexPair]

    @Field(key: "created_by")
    var createdBy: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(type: DTActionType, strokes: [PersistedDTStrokeIndexPair], roomId: PersistedDTRoom.IDValue,
         doodleId: PersistedDTDoodle.IDValue, createdBy: UUID, id: UUID? = nil) {
        self.type = type.rawValue
        self.$room.id = roomId
        self.$doodle.id = doodleId
        self.strokes = strokes
        self.createdBy = createdBy
        self.id = id
    }
}
