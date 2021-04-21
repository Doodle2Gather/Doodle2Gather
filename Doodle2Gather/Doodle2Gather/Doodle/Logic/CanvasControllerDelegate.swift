import UIKit
import DTSharedLibrary

/// Delegate for a `CanvasController`.
protocol CanvasControllerDelegate: AnyObject {

    /// Notifies the delegate that an action has been completed and needs to be dispatched.
    func dispatchPartialAction(_ action: DTPartialAdaptedAction)

    /// Informs the delegate that the zoom of the canvas has changed.
    func canvasZoomScaleDidChange(scale: CGFloat)

    /// Informs the delegate to refetch the doodles.
    func refetchDoodles()

    /// Informs the delegate that a stroke was selected, along with the color of the selected stroke.
    func strokeDidSelect(color: UIColor)

    /// Informs the delegate that the stroke was unselected.
    func strokeDidUnselect()

}
