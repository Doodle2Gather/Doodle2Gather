import Foundation
import Fluent
import DoodlingAdaptedLibrary

class AutoMergeController {
    let db: Database
    let newAction: DTAdaptedAction
    let logger: Logger
    
    init(db: Database, newAction: DTAdaptedAction) {
        self.db = db
        self.newAction = newAction
        self.logger = Logger(label: "AutoMergeController")
    }
    
    var added: Set<DTAdaptedStroke> {
        newAction.makeStrokesAdded()
    }
    
    var removed: Set<DTAdaptedStroke> {
        newAction.makeStrokesRemoved()
    }
    
    func getAllStrokesOfRoom() throws -> [PersistedDTStroke] {
        try PersistedDTStroke.getRoomAll(newAction.roomId, on: db).wait()
    }
    
    func checkMergeConflict() throws -> Bool {
        if removed.isEmpty {
            return false
        }
        let existingStrokes = try getAllStrokesOfRoom()
        
        for stroke in removed {
            if existingStrokes.filter({ stroke.isSameStroke(as: $0) }).count == 0 {
                return true
            }
        }
        return false
    }
}
