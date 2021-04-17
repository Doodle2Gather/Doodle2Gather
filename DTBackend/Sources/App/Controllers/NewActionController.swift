// import Foundation
// import Fluent
// import DTSharedLibrary
//
// class NewActionController {
//    let db: Database
//    let newAction: DTAdaptedAction
//    let persistedAction: PersistedDTAction
//    let logger: Logger
//
//    init(db: Database, newAction: DTAdaptedAction, persistedAction: PersistedDTAction) {
//        self.db = db
//        self.newAction = newAction
//        self.persistedAction = persistedAction
//        self.logger = Logger(label: "AutoMergeController")
//    }
//
//    var added: Set<DTAdaptedStroke> {
//        newAction.makeStrokesAdded()
//    }
//
//    var removed: Set<DTAdaptedStroke> {
//        newAction.makeStrokesRemoved()
//    }
//
//    func getAllStrokesOfRoom() -> EventLoopFuture<[PersistedDTStroke]> {
//        PersistedDTStroke.getRoomAll(newAction.roomId, on: db)
//    }
//
//    func checkMergeConflict() -> EventLoopFuture<Bool> {
//        getAllStrokesOfRoom().flatMapThrowing {
//            if self.removed.isEmpty {
//                return false
//            }
//
//            for stroke in self.removed {
//                if $0.contains(where: { stroke.isSameStroke(as: $0) }) {
//                    return true
//                }
//            }
//            return false
//        }
//    }
//
//    func getLatestDispatchedActions() -> EventLoopFuture<[DTAdaptedAction]> {
//        PersistedDTAction.getLatest(on: db)
//            .flatMapThrowing { actions in
//                actions.map(DTAdaptedAction.init)
//            }
//    }
//
//    func saveAction() -> EventLoopFuture<Void> {
//        persistedAction.save(on: self.db)
//    }
//
//    func addStrokes() -> [EventLoopFuture<Void>] {
//        added.compactMap { $0.makePersistedStroke().save(on: self.db) }
//    }
//
//    func removeStrokes() -> [EventLoopFuture<Void>] {
//        removed.compactMap {
//            PersistedDTStroke.getSingle($0.stroke, on: self.db)
//                .flatMap { $0.delete(on: self.db) }
//        }
//    }
//
//    func updateDatabase() -> Bool {
//        var success = true
//
//        addStrokes().forEach {
//            $0.whenComplete { res in
//                switch res {
//                case .failure(let err):
//                    self.logger.report(error: err)
//                    success = false
//                case .success:
//                    print("added")
//                }
//            }
//        }
//
//        removeStrokes().forEach {
//            print("try to remove")
//            $0.whenComplete { res in
//                switch res {
//                case .failure(let err):
//                    self.logger.report(error: err)
//                    success = false
//                case .success:
//                    print("removed")
//                }
//            }
//        }
//
//        saveAction().whenComplete { res in
//            switch res {
//            case .failure(let err):
//                self.logger.report(error: err)
//                success = false
//            case .success:
//                print("added action")
//            }
//        }
//        return success
//    }
//
//    func perform() -> EventLoopFuture<(isActionDenied: Bool, success: Bool)> {
//        checkMergeConflict()
//            .map { isActionDenied in
//                let success = self.updateDatabase()
//                return (isActionDenied, success)
//            }
//    }
// }
