import DTSharedLibrary

struct DTActionManager: ActionManager {

    /// Cache actions for undo and redo
    var undoActions = [DTActionProtocol]()
    var redoActions = [DTActionProtocol]()
    var userId: String?

    func transformAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTActionProtocol? {
        switch action.type {
        case .add:
            // There may have been strokes added while this newly added stroke was being
            // added. As such, we will shift the newly added stroke to the top of all
            // strokes in doodle.
            let length = doodle.strokes.count
            let stroke = DTEntityIndexPair(action.entities[0].entity, length, type: .stroke,
                                           entityId: action.entities[0].entityId, isDeleted: false)
            return DTPartialAdaptedAction(type: .add, doodleId: action.doodleId, strokes: [stroke],
                                          createdBy: action.createdBy)
        case .remove, .unremove:
            var editedStrokes = [DTEntityIndexPair]()
            let isDeleted = action.type == .remove

            for stroke in action.entities {
                if stroke.index >= doodle.strokes.count
                    || doodle.strokes[stroke.index].strokeId != stroke.entityId
                    || doodle.strokes[stroke.index].isDeleted == isDeleted {
                    continue
                }
                editedStrokes.append(stroke)
            }

            // All strokes that we intend to remove have been removed already.
            if editedStrokes.isEmpty {
                return nil
            }

            return DTPartialAdaptedAction(type: isDeleted ? .remove : .unremove, doodleId: action.doodleId,
                                          strokes: editedStrokes, createdBy: action.createdBy)
        case .modify:
            let oldStroke = action.entities[0]
            if oldStroke.index >= doodle.strokes.count
                || doodle.strokes[oldStroke.index].strokeId != oldStroke.entityId {
                return nil
            }
            // No change required if the stroke we intend to modify still exists as it is.
            return action
        }
    }

}
