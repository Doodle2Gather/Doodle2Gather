import UIKit
import DTSharedLibrary

/// The `CanvasGestureManagerDelegate` listens to a
/// `CanvasGestureManager` for any changes to the canvas as a
/// result of the gestures managed.
protocol CanvasGestureManagerDelegate: AnyObject {

    /// Informs the delegate that the zoom scale of the canvas has
    /// changed.
    func canvasZoomScaleDidChange(scale: CGFloat)

    /// Informs that delegate that a change has occurred to the canvas.
    func canvasViewDidChange(type: DTActionType)

    /// Informs the delegate that the user is currently performing a
    /// gesture.
    /// The relevance of this method depends on how the canvas update
    /// is implemented. If updating the canvas disrupts the user's current
    /// drawing, then this method should be used to protect against that.
    func setCanvasIsEditing(_ isEditing: Bool)

    /// Informs the delegate that a stroke with this color is being selected
    /// by the user.
    func strokeDidSelect(color: UIColor)

    /// Informs the delegate that the selected stroke has now been
    /// unselected.
    func strokeDidUnselect()

}
