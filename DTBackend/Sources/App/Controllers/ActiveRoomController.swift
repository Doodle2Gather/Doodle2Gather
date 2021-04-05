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

    /// Searching forward in the strokes array, to find the first matched stroke index
    /// `nil` is returned if no match is found
    func findFirstMatchIndex(for stroke: DTAdaptedStroke, startingFrom index: Int) -> Int? {
        for currIndex in (0...index).reversed() {
            if checkIfStrokeIsAtIndex(stroke, at: currIndex) {
                return currIndex
            }
        }
        return nil
    }
    
    func checkIfStrokeIsAtIndex(_ stroke: DTAdaptedStroke, at index: Int) -> Bool {
        getStroke(at: index) == stroke
    }
}

