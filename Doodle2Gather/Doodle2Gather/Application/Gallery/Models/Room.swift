import Foundation
import DTSharedLibrary

struct Room: DTRoom {
    var roomId: UUID
    var roomName: String

    init(roomId: UUID, roomName: String) {
        self.roomId = roomId
        self.roomName = roomName
    }

    init?(room: DTAdaptedRoom) {
        guard let id = room.roomId else {
            return nil
        }
        self.roomId = id
        self.roomName = room.name
    }
}
