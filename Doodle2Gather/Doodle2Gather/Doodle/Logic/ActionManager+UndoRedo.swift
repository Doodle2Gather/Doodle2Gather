extension ActionManager {

    var canUndo: Bool {
        !undoActions.isEmpty
    }

    var canRedo: Bool {
        !redoActions.isEmpty
    }

    mutating func undo() -> (action: DTPartialAdaptedAction?, newDoodle: DTDoodleWrapper?) {
        guard let latestAction = undoActions.popLast() else {
            return (nil, currentDoodle)
        }

        let newAction = latestAction.inverse()
        let newDoodle = dispatchAction(newAction)

        if newDoodle == nil {
            return (nil, currentDoodle)
        }

        redoActions.append(newAction)
        return (newAction, newDoodle)
    }

    mutating func redo() -> (action: DTPartialAdaptedAction?, newDoodle: DTDoodleWrapper?) {
        guard let latestAction = redoActions.popLast() else {
            return (nil, currentDoodle)
        }

        let newAction = latestAction.inverse()
        let newDoodle = dispatchAction(newAction)

        if newDoodle == nil {
            return (nil, currentDoodle)
        }

        undoActions.append(newAction)
        return (newAction, newDoodle)
    }

}
