import Foundation
import DTSharedLibrary

class ActiveRoomController {
    var activeRooms: [UUID: [UUID: DTAdaptedDoodle]]

    init() {
        activeRooms = [UUID: [UUID: DTAdaptedDoodle]]()
    }

    var activeRoomIds: Set<UUID> {
       Set(activeRooms.keys)
    }

    func isRoomActive(_ roomId: UUID) -> Bool {
        activeRoomIds.contains(roomId)
    }

    func process(_ action: DTAdaptedAction) {
        
        joinRoom(action.roomId) // create live copy of room
        
        let strokes = action.makeStrokes()
        
        switch action.type {
        case .add:
            if strokes.count != 1 {
                return
            }
            guard let strokeToAdd = strokes.first else {
                return
            }
            addStroke(strokeToAdd)
            
        case .remove:
            if strokes.isEmpty {
                return
            }
            removeStrokes(strokes)
            
        case .modify:
            if strokes.count != 2 {
                return
            }
            guard let originalStroke = strokes.first, let modifiedStroke = strokes.last else {
                return
            }
            modifyStroke(original: originalStroke, modified: modifiedStroke)
            
        default:
            return
        }
    }
    
    func joinRoom(_ roomId: UUID) {
        if !isRoomActive(roomId) {
            // activeRooms[roomId] = DTAdaptedDoodle(roomId: roomId)
        }
        
    }
    
    func addStroke(_ stroke: DTAdaptedStroke) {
        
    }
    
    func removeStrokes(_ strokes: [DTAdaptedStroke]) {
        
    }
    
    func modifyStroke(original: DTAdaptedStroke, modified: DTAdaptedStroke) {
        
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

