import Fluent
import Vapor

final class PersistedDTDoodle: Model, Content {
    static let schema = "doodles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "room_id")
    var room: PersistedDTRoom

    @Children(for: \.$doodle)
    var entities: [PersistedDTEntity]

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

    func getEntities() -> [PersistedDTEntity] {
        self.entities
    }

    func getStrokes() -> [PersistedDTEntity] {
        self.entities.filter { $0.type == .stroke }
    }

    func getText() -> [PersistedDTEntity] {
        self.entities.filter { $0.type == .text }
    }

    func getActions() -> [PersistedDTAction] {
        self.actions
    }

}
