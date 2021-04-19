import PencilKit
import DTSharedLibrary

extension ActionManager {

    /// Creates an action from two given doodles.
    mutating func createAction(oldDoodle: DTDoodleWrapper, newDoodle: PKDrawing,
                               actionType: DTActionType) -> DTPartialAdaptedAction? {
        guard let userId = DTAuth.user?.uid else {
            fatalError("You're not authenticated!")
        }

        let newStrokes = newDoodle.dtStrokes
        let oldStrokes = oldDoodle.drawing.dtStrokes

        // No change detected amongst undeleted strokes
        if newStrokes == oldStrokes {
            return nil
        }

        var action: DTPartialAdaptedAction?

        switch actionType {
        case .add:
            action = createAddAction(newStrokes: newStrokes, oldDoodle: oldDoodle, userId: userId)
        case .remove:
            action = createRemoveAction(newStrokes: newStrokes, oldDoodle: oldDoodle, userId: userId)
        case .modify:
            action = createModifyAction(newStrokes: newStrokes, oldDoodle: oldDoodle, userId: userId)
        case .unknown, .unremove:
            break
        }

        return action
    }

    private func createAddAction(newStrokes: [PKStroke], oldDoodle: DTDoodleWrapper,
                                 userId: String) -> DTPartialAdaptedAction? {
        let oldStrokes = oldDoodle.drawing.dtStrokes
        guard newStrokes.count == oldStrokes.count + 1, let stroke = newStrokes.last else {
            return nil
        }

        let strokeWrapper = DTStrokeWrapper(stroke: stroke, strokeId: UUID(), createdBy: userId)
        return DTPartialAdaptedAction(type: .add, doodleId: oldDoodle.doodleId,
                                      strokes: [(strokeWrapper, oldDoodle.strokes.count)],
                                      createdBy: userId)
    }

    private func createRemoveAction(newStrokes: [PKStroke], oldDoodle: DTDoodleWrapper,
                                    userId: String) -> DTPartialAdaptedAction? {
        let oldStrokes = oldDoodle.drawing.dtStrokes
        if newStrokes.count > oldStrokes.count {
            return nil
        }

        let newStrokesSet = Set(newStrokes)
        var removedStrokes = [(DTStrokeWrapper, Int)]()

        for case (let index, var stroke)? in oldDoodle.strokes.enumerated() {
            if stroke.isDeleted {
                continue
            }

            // Stroke has been newly removed
            if !newStrokesSet.contains(stroke.stroke) {
                stroke.isDeleted = true
                removedStrokes.append((stroke, index))
            }
        }

        if removedStrokes.isEmpty {
            return nil
        }

        return DTPartialAdaptedAction(type: .remove, doodleId: oldDoodle.doodleId,
                                      strokes: removedStrokes, createdBy: userId)
    }

    private func createModifyAction(newStrokes: [PKStroke], oldDoodle: DTDoodleWrapper,
                                    userId: String) -> DTPartialAdaptedAction? {
        let oldStrokes = oldDoodle.drawing.dtStrokes
        if newStrokes.count != oldStrokes.count {
            return nil
        }

        var newStrokeIndex = 0

        for (index, stroke) in oldDoodle.strokes.enumerated() {
            if stroke.isDeleted {
                continue
            }
            // Stroke has been modified
            if !(newStrokes[newStrokeIndex] == stroke.stroke) {
                let newStrokeWrapper = DTStrokeWrapper(stroke: newStrokes[newStrokeIndex],
                                                       strokeId: UUID(), createdBy: stroke.createdBy)
                return DTPartialAdaptedAction(type: .modify, doodleId: oldDoodle.doodleId,
                                              strokes: [(stroke, index), (newStrokeWrapper, index)],
                                              createdBy: userId)
            }
            newStrokeIndex += 1
        }

        return nil
    }

}
