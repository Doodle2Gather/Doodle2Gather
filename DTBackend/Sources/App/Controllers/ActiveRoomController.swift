import Foundation
import DTSharedLibrary

class ActiveRoomController {
    var activeRooms: [UUID: DTAdaptedDoodle]

    init() {
        activeRooms = [UUID: DTAdaptedDoodle]()
    }

    var activeRoomIds: Set<UUID> {
       Set(activeRooms.keys)
    }

    func isRoomActive(roomId: UUID) -> Bool {
        activeRoomIds.contains(roomId)
    }

    func addActiveRoom(roomId: UUID) {
        activeRooms[roomId] = DTAdaptedDoodle(roomId: roomId)
    }

}

extension DTAdaptedDoodle {

}
