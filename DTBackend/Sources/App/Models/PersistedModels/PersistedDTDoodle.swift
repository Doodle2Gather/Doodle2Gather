import Fluent
import Vapor

final class PersistedDTDoodle: Model {
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
    
    init(id: UUID? = nil, roomId: PersistedDTRoom.IDValue) {
        self.id = id
        self.$room.id = roomId
    }
    
}
