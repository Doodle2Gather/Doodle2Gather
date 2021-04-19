extension ActionManager {

    var canUndo: Bool {
        !undoActions.isEmpty
    }

    var canRedo: Bool {
        !redoActions.isEmpty
    }

    mutating func undo() -> DTPartialAdaptedAction? {
        guard let latestAction = undoActions.popLast() else {
            return nil
        }

        let action = latestAction.inverse()
        redoActions.append(action)
        return action
    }

    mutating func redo() -> DTPartialAdaptedAction? {
        guard let latestAction = redoActions.popLast() else {
            return nil
        }

        let action = latestAction.inverse()
        undoActions.append(action)
        return action
    }

    mutating func addNewActionToUndo(_ action: DTPartialAdaptedAction) {
        undoActions.append(action)
        redoActions = []
    }

}
