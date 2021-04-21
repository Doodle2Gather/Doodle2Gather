// MARK: - Action Application

extension DTActionManager {

    func applyAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTDoodleWrapper? {
        switch action.type {
        case .add:
            return applyAddAction(action, on: doodle)
        case .remove:
            return applyRemoveOrUnremoveAction(action, on: doodle)
        case .unremove:
            return applyRemoveOrUnremoveAction(action, on: doodle, isRemove: false)
        case .modify:
            return applyModifyAction(action, on: doodle)
        }
    }

    /// Applies an add action on a given doodle.
    ///
    /// - Returns: `nil` if the index of the stroke to be added does not
    ///   match up; otherwise, the doodle with the stroke added.
    private func applyAddAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTDoodleWrapper? {
        var doodle = doodle
        let strokes = action.getStrokes()
        if doodle.strokes.count != strokes[0].index {
            return nil
        }
        doodle.strokes.append(strokes[0].stroke)
        return doodle
    }

    /// Applies a remove or unremove action on a given doodle.
    ///
    /// - Returns: `nil` if any stroke that was to be removed does not exist
    ///   or has an invalid index; otherwise, the doodle with the strokes removed.
    private func applyRemoveOrUnremoveAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper,
                                             isRemove: Bool = true) -> DTDoodleWrapper? {
        var doodle = doodle
        let strokes = action.getStrokes()

        for (stroke, index) in strokes {
            if index >= doodle.strokes.count {
                return nil
            }

            let currentStroke = doodle.strokes[index]

            if stroke.strokeId != currentStroke.strokeId {
                return nil
            }
            doodle.strokes[index].isDeleted = isRemove
        }

        return doodle
    }

    /// Applies a modify action on a given doodle.
    ///
    /// - Returns: `nil` if an unexpected number of strokes is provided, or if
    ///   the stroke that was to be modified does not exist or has an invalid index;
    ///   otherwise, the doodle with the stroke modified.
    private func applyModifyAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTDoodleWrapper? {
        var doodle = doodle
        let strokes = action.getStrokes()

        guard strokes.count == 2 else {
            return nil
        }

        let (originalStroke, originalIndex) = strokes[0]
        let (newStroke, newIndex) = strokes[1]

        if originalIndex != newIndex || newIndex >= doodle.strokes.count
            || doodle.strokes[newIndex].strokeId != originalStroke.strokeId {
            return nil
        }

        doodle.strokes[newIndex] = newStroke
        return doodle
    }
}
