import PencilKit
import DTSharedLibrary

struct ActionManager {

    /// Cached previous copy of the canvas.
    var currentDoodle = DTDoodleWrapper()

    /// Cache actions for undo and redo
    var undoActions = [DTPartialAdaptedAction]()
    var redoActions = [DTPartialAdaptedAction]()

}

// MARK: - Action Creation

extension ActionManager {

    /// Creates an action based on a new doodle and an action type.
    ///
    /// - Returns: A tuple containing an action that can be dispatch to
    ///   others in the same room + an updated doodle.
    mutating func createActionAndNewDoodle(doodle: PKDrawing, actionType: DTActionType) ->
            (action: DTPartialAdaptedAction?, newDoodle: DTDoodleWrapper?) {
        guard let userId = DTAuth.user?.uid else {
            fatalError("You're not authenticated!")
        }

        let newStrokes = doodle.dtStrokes
        let oldStrokes = currentDoodle.drawing.dtStrokes

        // No change detected amongst undeleted strokes
        if newStrokes == oldStrokes {
            return (nil, nil)
        }

        var action: DTPartialAdaptedAction?

        switch actionType {
        case .add:
            action = createAddActionAndUpdateCurrentDoodle(newStrokes: newStrokes,
                                                           oldStrokes: oldStrokes,
                                                           userId: userId)
        case .remove:
            action = createRemoveActionAndUpdateCurrentDoodle(newStrokes: newStrokes,
                                                              oldStrokes: oldStrokes,
                                                              userId: userId)
        case .modify:
            action = createModifyActionAndUpdateCurrentDoodle(newStrokes: newStrokes,
                                                              oldStrokes: oldStrokes,
                                                              userId: userId)
        case .unknown, .unremove:
            break
        }

        if let action = action {
            undoActions.append(action)
            redoActions = []
        }

        return (action, currentDoodle)
    }

    mutating func createAddActionAndUpdateCurrentDoodle(newStrokes: [PKStroke], oldStrokes: [PKStroke],
                                                        userId: String) -> DTPartialAdaptedAction? {
        guard newStrokes.count == oldStrokes.count + 1, let stroke = newStrokes.last else {
            fatalError("Invalid canvas state!")
        }

        let strokeWrapper = DTStrokeWrapper(stroke: stroke, strokeId: UUID(), createdBy: userId)

        let action = DTPartialAdaptedAction(type: .add, doodleId: currentDoodle.doodleId,
                                            strokes: [(strokeWrapper, currentDoodle.strokes.count)],
                                            createdBy: userId)
        currentDoodle.strokes.append(strokeWrapper)
        return action
    }

    mutating func createRemoveActionAndUpdateCurrentDoodle(newStrokes: [PKStroke], oldStrokes: [PKStroke],
                                                           userId: String) -> DTPartialAdaptedAction? {
        if newStrokes.count > oldStrokes.count {
            fatalError("Invalid canvas state!")
        }
        let newStrokesSet = Set(newStrokes)
        var removedStrokes = [(DTStrokeWrapper, Int)]()

        for (index, stroke) in currentDoodle.strokes.enumerated() {
            if stroke.isDeleted {
                continue
            }
            // Stroke has been removed
            if !newStrokesSet.contains(stroke.stroke) {
                removedStrokes.append((stroke, index))
                currentDoodle.strokes[index].isDeleted = true
            }
        }

        if removedStrokes.isEmpty {
            return nil
        }

        return DTPartialAdaptedAction(type: .remove, doodleId: currentDoodle.doodleId,
                                      strokes: removedStrokes, createdBy: userId)
    }

    mutating func createModifyActionAndUpdateCurrentDoodle(newStrokes: [PKStroke], oldStrokes: [PKStroke],
                                                           userId: String) -> DTPartialAdaptedAction? {
        if newStrokes.count != oldStrokes.count {
            fatalError("Invalid canvas state!")
        }

        var newStrokeIndex = 0

        for (index, stroke) in currentDoodle.strokes.enumerated() {
            if stroke.isDeleted {
                continue
            }
            // Stroke has been modified
            if !(newStrokes[newStrokeIndex] == stroke.stroke) {
                let newStrokeWrapper = DTStrokeWrapper(stroke: newStrokes[newStrokeIndex],
                                                       strokeId: UUID(), createdBy: stroke.createdBy)
                currentDoodle.strokes[index] = newStrokeWrapper
                return DTPartialAdaptedAction(type: .modify, doodleId: currentDoodle.doodleId,
                                              strokes: [(stroke, index), (newStrokeWrapper, index)],
                                              createdBy: userId)
            }
            newStrokeIndex += 1
        }

        return nil
    }

}

// MARK: - Action Reception + Handling

extension ActionManager {

    /// Dispatches an action received from the socket to the current state.
    /// Doing so through this method results in no action being re-fired off.
    mutating func dispatchAction(_ action: DTActionProtocol) -> DTDoodleWrapper? {
        do {
            let pairs = action.getStrokes()
            guard let firstStroke = pairs.first else {
                throw DTCanvasError.cannotParseStroke
            }

            switch action.type {
            case .add:
                return try addPairQuietly(stroke: firstStroke.stroke, index: firstStroke.index)
            case .remove:
                return try removeOrUnremovePairsQuietly(pairs: pairs)
            case .unremove:
                return try removeOrUnremovePairsQuietly(pairs: pairs, isUnremove: true)
            case .modify:
                return try modifyPairQuietly(pairs: pairs)
            case .unknown:
                return nil
            }
        } catch {
            DTLogger.error(error.localizedDescription)
            return nil
        }
    }

    /// Adds a given stroke at the given index without any action fired off.
    /// This method will throw an error if the indices do not match up.
    ///
    /// - Throws: DTCanvasError.indexMismatch if the indices do not match up.
    private mutating func addPairQuietly(stroke: DTStrokeWrapper, index: Int) throws -> DTDoodleWrapper {
        if currentDoodle.strokes.count != index {
            DTLogger.error("Failed to add pairs quietly")
            throw DTCanvasError.indexMismatch
        }
        self.currentDoodle.strokes.append(stroke)
        return currentDoodle
    }

    /// Removes or unremoves the given strokes at the given indices without any action fired off.
    /// This method will throw an error if the indices do not match up.
    ///
    /// - Throws: DTCanvasError.indexMismatch if the indices do not match up.
    private mutating func removeOrUnremovePairsQuietly(pairs: [(DTStrokeWrapper, Int)],
                                                       isUnremove: Bool = false) throws -> DTDoodleWrapper {
        for (stroke, index) in pairs {
            if index >= currentDoodle.strokes.count {
                DTLogger.error("Failed to remove/unremove pairs quietly")
                throw DTCanvasError.indexMismatch
            }

            let currentStroke = currentDoodle.strokes[index]

            if stroke.strokeId != currentStroke.strokeId {
                DTLogger.error("Failed to remove/unremove pairs quietly")
                throw DTCanvasError.indexMismatch
            }
            currentDoodle.strokes[index].isDeleted = !isUnremove
        }
        return currentDoodle
    }

    /// Modifies the given stroke at the given index without any action fired off.
    /// This method will throw an error if the indices do not match up.
    ///
    /// - Throws: DTCanvasError.indexMismatch if the indices do not match up.
    private mutating func modifyPairQuietly(pairs: [(DTStrokeWrapper, Int)]) throws -> DTDoodleWrapper {
        guard pairs.count == 2 else {
            DTLogger.error("Failed to modify pairs quietly")
            throw DTCanvasError.indexMismatch
        }

        let (originalStroke, originalIndex) = pairs[0]
        let (newStroke, newIndex) = pairs[1]
        if originalIndex != newIndex || newIndex >= currentDoodle.strokes.count
            || currentDoodle.strokes[newIndex].strokeId != originalStroke.strokeId {
            DTLogger.error("Failed to modify pairs quietly")
            throw DTCanvasError.indexMismatch
        }
        currentDoodle.strokes[newIndex] = newStroke
        return currentDoodle
    }

}
