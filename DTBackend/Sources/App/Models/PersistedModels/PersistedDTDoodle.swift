import Fluent
import Vapor

/// persisted model and schema which represents `DTAdaptedDoodle` and `DTDoodle`
final class PersistedDTDoodle: Model, Content {
    static let schema = "doodles"

    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    @Children(for: \.$doodle)
    var entities: [PersistedDTEntity]

    init() { }

    init(roomId: PersistedDTRoom.IDValue, id: UUID? = nil) {
        self.id = id
        self.$room.id = roomId
    }

    init(room: PersistedDTRoom, id: UUID? = nil) {
        self.id = id
        self.$room.id = room.id!
    }

    func getEntities() -> [PersistedDTEntity] {
        self.entities
    }

    func getStrokes() -> [PersistedDTEntity] {
        self.entities.filter { $0.type == .stroke }
    }

}
