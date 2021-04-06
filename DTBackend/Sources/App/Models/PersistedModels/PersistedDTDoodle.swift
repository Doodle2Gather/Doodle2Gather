import Fluent
import Vapor

final class PersistedDTDoodle: Model, Content {
    static let schema = "doodles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    @Children(for: \.$doodle)
    var strokes: [PersistedDTStroke]

    @Children(for: \.$doodle)
    var actions: [PersistedDTAction]

    init() { }

    init(roomId: PersistedDTRoom.IDValue, id: UUID? = nil) {
        self.id = id
        self.$room.id = roomId
    }

    init(room: PersistedDTRoom, id: UUID? = nil) {
        self.id = id
        self.$room.id = room.id!
    }

}
