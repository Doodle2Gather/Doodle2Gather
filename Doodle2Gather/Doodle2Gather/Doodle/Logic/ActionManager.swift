import DTSharedLibrary

struct ActionManager {

    /// Cache actions for undo and redo
    var undoActions = [DTPartialAdaptedAction]()
    var redoActions = [DTPartialAdaptedAction]()

    func translateAction(_ action: DTPartialAdaptedAction, on doodle: DTDoodleWrapper) -> DTPartialAdaptedAction? {
        switch action.type {
        case .add:
            let length = doodle.strokes.count
            let stroke = DTStrokeIndexPair(action.strokes[0].stroke, length,
                                           strokeId: action.strokes[0].strokeId, isDeleted: false)
            return DTPartialAdaptedAction(type: .add, doodleId: action.doodleId, strokes: [stroke],
                                          createdBy: action.createdBy)
        case .remove:
            var removedStrokes = [DTStrokeIndexPair]()

            for stroke in action.strokes {
                if stroke.index >= doodle.strokes.count || doodle.strokes[stroke.index].strokeId != stroke.strokeId
                    || doodle.strokes[stroke.index].isDeleted {
                    continue
                }
                removedStrokes.append(stroke)
            }

            if removedStrokes.isEmpty {
                return nil
            }

            return DTPartialAdaptedAction(type: .remove, doodleId: action.doodleId, strokes: removedStrokes,
                                          createdBy: action.createdBy)
        case .modify:
            let oldStroke = action.strokes[0]
            if oldStroke.index >= doodle.strokes.count
                || doodle.strokes[oldStroke.index].strokeId != oldStroke.strokeId {
                return nil
            }
            return action
        default:
            return nil
        }
    }

}
