import Foundation
import DTSharedLibrary

struct Room: DTRoom {
    var roomId: UUID
    var roomName: String
    var inviteCode: String

    init(roomId: UUID, roomName: String, inviteCode: String) {
        self.roomId = roomId
        self.roomName = roomName
        self.inviteCode = inviteCode
    }

    init?(room: DTAdaptedRoom) {
        guard let id = room.roomId else {
            return nil
        }
        self.roomId = id
        self.roomName = room.name
        self.inviteCode = room.inviteCode
    }
}
