import DTSharedLibrary

struct ActionManager {

    /// Cache actions for undo and redo
    var undoActions = [DTPartialAdaptedAction]()
    var redoActions = [DTPartialAdaptedAction]()

    func translateAction(_ action: DTPartialAdaptedAction, on doodle: DTDoodleWrapper) -> DTPartialAdaptedAction? {
        switch action.type {
        case .add:
            let length = doodle.strokes.count
            let stroke = DTEntityIndexPair(action.entities[0].entity, length, type: .stroke,
                                           entityId: action.entities[0].entityId, isDeleted: false)
            return DTPartialAdaptedAction(type: .add, doodleId: action.doodleId, strokes: [stroke],
                                          createdBy: action.createdBy)
        case .remove:
            var removedStrokes = [DTEntityIndexPair]()

            for stroke in action.entities {
                if stroke.index >= doodle.strokes.count || doodle.strokes[stroke.index].strokeId != stroke.entityId
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
            let oldStroke = action.entities[0]
            if oldStroke.index >= doodle.strokes.count
                || doodle.strokes[oldStroke.index].strokeId != oldStroke.entityId {
                return nil
            }
            return action
        default:
            return nil
        }
    }

}
