import PencilKit
import DTSharedLibrary

struct ActionManager {

    /// Cached previous copy of the canvas.
    var currentDoodle = DTDoodleWrapper()

    // var undoActions = [Int: [(type: DTActionType, strokes: [(PKStroke, Int)])]]()
    // var redoActions = [Int: [(type: DTActionType, strokes: [(PKStroke, Int)])]]()

}

// MARK: - Action Creation

extension ActionManager {

    mutating func createActionAndNewDoodle(doodle: PKDrawing, actionType: DTActionType) -> (action: DTPartialAction?,
                                                                                   newDoodle: DTDoodleWrapper?) {
        guard let userId = DTAuth.user?.uid else {
            fatalError("You're not authenticated!")
        }

        let newStrokes = doodle.dtStrokes
        let oldStrokes = currentDoodle.drawing.dtStrokes
        var action: DTPartialAction?

        switch actionType {
        case .add:
            if newStrokes.count != oldStrokes.count + 1 {
                fatalError("Invalid canvas state!")
            }
            guard let stroke = doodle.strokes.last else {
                fatalError("Invalid canvas state!")
            }
            let strokeWrapper = DTStrokeWrapper(stroke: stroke, strokeId: UUID(), createdBy: userId)

            action = DTPartialAction(type: .add, doodleId: currentDoodle.doodleId,
                                     strokes: [(strokeWrapper, currentDoodle.strokes.count + 1)],
                                     createdBy: userId)
            currentDoodle.strokes.append(strokeWrapper)
        case .remove:
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
                return (nil, nil)
            }

            action = DTPartialAction(type: .remove, doodleId: currentDoodle.doodleId,
                                     strokes: removedStrokes, createdBy: userId)
        case .modify:
            if newStrokes.count != oldStrokes.count {
                fatalError("Invalid canvas state!")
            }

            var newStrokeIndex = 0

            for (index, stroke) in currentDoodle.strokes.enumerated() {
                if stroke.isDeleted {
                    continue
                }
                // Stroke has been removed
                if !(newStrokes[newStrokeIndex] == stroke.stroke) {
                    let newStrokeWrapper = DTStrokeWrapper(stroke: newStrokes[newStrokeIndex],
                                                           strokeId: UUID(), createdBy: userId)
                    action = DTPartialAction(type: .modify, doodleId: currentDoodle.doodleId,
                                             strokes: [(stroke, index), (newStrokeWrapper, index)], createdBy: userId)
                    currentDoodle.strokes[index] = newStrokeWrapper
                    break
                }
                newStrokeIndex += 1
            }
        case .unknown, .unremove:
            break
        }

        return (action, currentDoodle)
    }

}

// MARK: - Action Reception + Handling

extension ActionManager {

    mutating func dispatchAction(_ action: DTAction) -> DTDoodleWrapper? {
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

    private mutating func addPairQuietly(stroke: DTStrokeWrapper, index: Int) throws -> DTDoodleWrapper {
        if currentDoodle.strokes.count != index {
            DTLogger.error("Failed to add pairs quietly")
            throw DTCanvasError.indexMismatch
        }
        self.currentDoodle.strokes.append(stroke)
        return currentDoodle
    }

    /// Removes or unremoves the given pairs quietly.
    private mutating func removeOrUnremovePairsQuietly(pairs: [(DTStrokeWrapper, Int)], isUnremove: Bool = false) throws -> DTDoodleWrapper {
        for (stroke, index) in pairs {
            if index >= currentDoodle.strokes.count {
                DTLogger.error("Failed to remove pairs quietly")
                throw DTCanvasError.indexMismatch
            }

            let currentStroke = currentDoodle.strokes[index]

            if stroke.strokeId != currentStroke.strokeId {
                DTLogger.error("Failed to remove pairs quietly")
                throw DTCanvasError.indexMismatch
            }
            currentDoodle.strokes[index].isDeleted = !isUnremove
        }
        return currentDoodle
    }

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
