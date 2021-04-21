extension DTActionManager {

    var canUndo: Bool {
        !undoActions.isEmpty
    }

    var canRedo: Bool {
        !redoActions.isEmpty
    }

    mutating func undo() -> DTActionProtocol? {
        guard let latestAction = undoActions.popLast() else {
            return nil
        }

        let action = latestAction.invert()
        redoActions.append(action)
        return action
    }

    mutating func redo() -> DTActionProtocol? {
        guard let latestAction = redoActions.popLast() else {
            return nil
        }

        let action = latestAction.invert()
        undoActions.append(action)
        return action
    }

    mutating func addNewActionToUndo(_ action: DTActionProtocol) {
        undoActions.append(action)
        redoActions = []
    }

}
