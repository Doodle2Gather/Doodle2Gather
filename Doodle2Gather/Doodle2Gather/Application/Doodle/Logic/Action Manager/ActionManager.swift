import PencilKit
import DTSharedLibrary

/// `ActionManager` helps with stateless action creation, transformation and
/// applications, as well as stateful action tracking.
///
/// It should store a copy of the actions to undo and redo.
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
                      actionType: DTActionType) -> DTActionProtocol?

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
    ///   - `action`: The action to transform.
    ///   - `doodle`: The state to transform this action to be applicable for.
    ///
    /// - Returns: `nil` if the change is not applicable for the state of `doodle`;
    ///   otherwise, a transformed action.
    func transformAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTActionProtocol?

    /// Applies an action to a given doodle state and returns the new state.
    ///
    /// If the application of the action fails, `nil` will be returned.
    ///
    /// - Parameters:
    ///   - `action`: The action that is to be applied.
    ///   - `doodle`: The state to apply this action on.
    ///
    /// - Returns: `nil` if the action is not applicable for the state of `doodle`;
    ///   otherwise, a new state with the change applied.
    func applyAction(_ action: DTActionProtocol, on doodle: DTDoodleWrapper) -> DTDoodleWrapper?

    // MARK: - Stateful Operations

    /// Whether the application can undo.
    var canUndo: Bool { get }
    
    /// Whether the application can redo.
    var canRedo: Bool { get }

    /// Adds a new action that can be undone.
    /// This should clear any actions that can be redone.
    mutating func addNewActionToUndo(_ action: DTActionProtocol)

    /// Returns the latest action by the user that can be undone.
    ///
    /// This action is already inverted, in that it can be directly applied to reverse
    /// the latest change that the user has performed.
    ///
    /// This undone action should also be redoable subsequently.
    ///
    /// - Returns: `nil` if there's no action that can be undone; otherwise,
    ///   an inverted action.
    mutating func undo() -> DTActionProtocol?

    /// Returns the latest action by the user that can be redone.
    ///
    /// This action is already inverted, in that it can be directly applied to reverse
    /// the latest undo that the user has performed.
    ///
    /// This redone action should also be undoable subsequently.
    ///
    /// - Returns: `nil` if there's no action that can be redone; otherwise,
    ///   an inverted action.
    mutating func redo() -> DTActionProtocol?

}
