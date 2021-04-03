import Foundation
import Fluent
import DoodlingAdaptedLibrary

class AutoMergeController {
    let db: Database
    let newAction: DTAdaptedAction
    let persistedAction: PersistedDTAction
    let logger: Logger

    init(db: Database, newAction: DTAdaptedAction, persistedAction: PersistedDTAction) {
        self.db = db
        self.newAction = newAction
        self.persistedAction = persistedAction
        self.logger = Logger(label: "AutoMergeController")
    }

    var added: Set<DTAdaptedStroke> {
        newAction.makeStrokesAdded()
    }

    var removed: Set<DTAdaptedStroke> {
        newAction.makeStrokesRemoved()
    }

    func getAllStrokesOfRoom() -> EventLoopFuture<[PersistedDTStroke]> {
        PersistedDTStroke.getRoomAll(newAction.roomId, on: db)
    }

    func checkMergeConflict() -> EventLoopFuture<Bool> {
        getAllStrokesOfRoom().flatMapThrowing {
            if self.removed.isEmpty {
                return false
            }

            for stroke in self.removed {
                if $0.filter({ stroke.isSameStroke(as: $0) }).isEmpty {
                    return true
                }
            }
            return false
        }
    }

    var latestDispatchedActions = [DTAdaptedAction]()

    func getLatestDispatchedActions() {
        PersistedDTAction.getLatest(on: db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedAction.init)
            }
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success(let actions):
                    self.latestDispatchedActions = actions
                }
            }
    }

    func saveAction() -> EventLoopFuture<Void> {
        persistedAction.save(on: self.db)
    }

    func addStrokes() -> [EventLoopFuture<Void>] {
        added.compactMap { $0.makePersistedStroke().save(on: self.db) }
    }

    func removeStrokes() -> [EventLoopFuture<Void>] {
        removed.compactMap {
            PersistedDTStroke.getSingle($0.stroke, on: self.db)
                .flatMap { $0.delete(on: self.db) }
        }
    }

    func updateDatabase() -> Bool {
        addStrokes().forEach {
            $0.whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success:
                    print("added")
                }
            }
        }

        removeStrokes().forEach {
            print("try to remove")
            $0.whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success:
                    print("removed")
                }
            }
        }

        saveAction().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success:
                print("added action")
            }
        }
        return true
    }

    func perform() -> EventLoopFuture<(isActionDenied: Bool, message: String)> {
        checkMergeConflict()
            .map { isActionDenied in
                var message: String

                if isActionDenied {
                    message = "Merge conflict."
                } else {
                    message = self.updateDatabase() ? "Action added" : "Something went wrong adding the action."
                }

                return (isActionDenied, message)
            }
    }
}
