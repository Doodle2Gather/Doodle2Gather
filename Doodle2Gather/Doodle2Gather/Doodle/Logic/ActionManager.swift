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

    func dispatchAction(_ action: DTAction) -> DTDoodleWrapper? {
        do {
            let pairs = action.getStrokes()
            guard let firstStroke: (stroke: DTStrokeWrapper, index: Int) = pairs.first else {
                throw DTCanvasError.cannotParseStroke
            }
            return nil

//            switch action.type {
//            case .add:
//                return try addPairQuietly(pair: firstStroke)
//            case .remove:
//                return try removePairsQuietly(pairs: pairs)
//            case .unremove:
//                return try unremovePairsQuietly(pairs: pairs)
//            case .modify:
//                return try modifyPairQuietly(pair: firstStroke)
//            case .unknown:
//                return
//            }
        } catch {
            DTLogger.error(error.localizedDescription)
            return nil
        }
    }
//
//    private func addPairQuietly(pair: (stroke: DTStrokeWrapper, index: Int)) throws {
//        if currentDoodle.strokes.count != index {
//            DTLogger.error("Failed to add pairs quietly")
//            throw DTCanvasError.indexMismatch
//        }
//        currentDoodle.strokes.append(stroke)
//        canvasView.drawing = doodleCopy
//    }
//
//    /// Removes the given pairs quietly.
//    private func removePairsQuietly(indices: [Int], strokes: [PKStroke]) throws {
//        var doodleCopy = currentDoodle
//        for (i, index) in indices.enumerated() {
//            if index >= doodleCopy.strokes.count {
//                DTLogger.error("Failed to remove pairs quietly")
//                throw DTCanvasError.indexMismatch
//            }
//            let stroke = doodleCopy.strokes[index]
//
//            if stroke != strokes[i] {
//                DTLogger.error("Failed to remove pairs quietly")
//                throw DTCanvasError.indexMismatch
//            }
//            doodleCopy.removeStrokes([stroke])
//        }
//        currentDoodle = doodleCopy
//        canvasView.drawing = doodleCopy
//    }
//
//    private func modifyPairQuietly(index: Int, stroke: PKStroke) throws {
//        var doodleCopy = currentDoodle
//        if index >= doodleCopy.strokes.count || doodleCopy.strokes[index] != stroke {
//            DTLogger.error("Failed to modify pairs quietly")
//            throw DTCanvasError.indexMismatch
//        }
//        doodleCopy.strokes[index] = stroke
//        currentDoodle = doodleCopy
//        canvasView.drawing = doodleCopy
//    }

}
