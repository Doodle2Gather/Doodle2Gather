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
            if existingStrokes.contains({ stroke.isSameStroke(as: $0) }) {
                return true
            }
        }
        return false
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

    func perform() throws -> (success: Bool, message: String) {
        let hasConflict = try checkMergeConflict()

        var success: Bool
        var message: String

        if hasConflict {
            success = false
            message = "Merge conflict."
        } else {
            success = updateDatabase()
            message = success ? "Action added" : "Something went wrong adding the action."
        }

        return (success, message)
    }
}
