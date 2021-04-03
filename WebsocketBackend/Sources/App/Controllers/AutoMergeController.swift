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
            if existingStrokes.filter({ stroke.isSameStroke(as: $0) }).isEmpty {
                return true
            }
        }
        return false
    }
    
    func getLatestDispatchedActions() throws -> [DTAdaptedAction] {
        try PersistedDTAction.getLatest(on: db).wait()
            .map{ DTAdaptedAction(action: $0) }
    }

    func saveAction() -> EventLoopFuture<Void> {
        self.newAction.makePersistedAction().save(on: self.db)
    }

    func addStrokes() -> [EventLoopFuture<Void>] {
        added.compactMap { $0.makePersistedStroke().save(on: self.db) }
    }

    func removeStrokes() throws -> [EventLoopFuture<Void>] {
        removed.compactMap {
            PersistedDTStroke.getSingle($0.stroke, on: self.db)
                .flatMap { $0.delete(on: self.db) }
        }
    }

    func updateDatabase() -> Bool {
        do {
            let tasks = try [saveAction()] + addStrokes() + removeStrokes()
            try tasks.forEach { try $0.wait() }
        } catch {
            logger.report(error: error)
            return false
        }

        return true
    }

    func perform() throws -> (isActionDenied: Bool, message: String) {
        let isActionDenied = try checkMergeConflict()

        var message: String

        if isActionDenied {
            message = "Merge conflict."
        } else {
            message = updateDatabase() ? "Action added" : "Something went wrong adding the action."
        }

        return (isActionDenied, message)
    }
}
