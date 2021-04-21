import PencilKit
import DTSharedLibrary

protocol ActionManager {

    // MARK: - Stateless Operations

    /// Creates a new action by comparing an old doodle (with wrapper) with a newer doodle.
    ///
    /// This method determines if a valid change of the given `actionType` was performed,
    /// and if only a single change was made. If either of these conditions are not met, then
    /// this method will return `nil`.
    ///
    /// - Parameters:
    ///   - `oldDoodle`: The previous doodle wrapper prior to the **single** change
    ///      performed.
    ///   - `newDoodle`: The new doodle (non-wrapper) with the change performed.
    ///   - `actionType`: The type of the action performed.
    ///
    /// - Returns: `nil` if no change was detected or if the change does not match the
    ///   `actionType` or if more than one change was detected; otherwise, an action
    ///   that when applied to the state of `oldDoodle` will give us the state of `newDoodle`.
    ///   This returned action will be recognised as being created by the current user.
    func createAction(oldDoodle: DTDoodleWrapper, newDoodle: PKDrawing,
                      actionType: DTActionType) -> DTPartialAdaptedAction?

    /// Transforms an action to be applicable on a new doodle.
    ///
    /// This method's expected behaviour follows similar principles as operational transform,
    /// though more primitive. It should ensure that, for any given `action`, the change that
    /// it is trying to make can be made on this new `doodle` and a difference can be
    /// observed.
    ///
    /// This also means that if no difference can be observed, e.g. the `action` attempts to
    /// remove a stroke that has already been removed in `doodle`, then `nil` will be
    /// returned.
    ///
    /// - Parameters:
    ///   - `action`: The action that we wish to transform.
    ///   - `doodle`: The state that we wish to transform this action to be applicable for.
    ///
    /// - Returns: `nil` if the change is not applicable for the state of `doodle`;
    ///   otherwise, a transformed action.
    func transformAction(_ action: DTPartialAdaptedAction, on doodle: DTDoodleWrapper) -> DTPartialAdaptedAction?

    /// Applies an action to a given doodle state and returns the new state.
    func applyAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTDoodleWrapper?

    // MARK: - Stateful Operations

    var canUndo: Bool { get }
    var canRedo: Bool { get }

    mutating func addNewActionToUndo(_ action: DTPartialAdaptedAction)

    mutating func undo() -> DTPartialAdaptedAction?

    mutating func redo() -> DTPartialAdaptedAction?

}
