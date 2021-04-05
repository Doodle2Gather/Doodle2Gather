import CoreGraphics
import DTFrontendLibrary
import DTSharedLibrary

/// Delegate for a `CanvasController`.
protocol CanvasControllerDelegate: AnyObject {

    /// Notifies the delegate that an action has been completed.
    func actionDidFinish(action: DTNewAction)

    /// Dispatches the action to the canvas controller.
    func dispatchChanges<S: DTStroke>(type: DTActionType, strokes: [(S, Int)])

    /// Informs the delegate that the zoom of the canvas has changed.
    func canvasZoomScaleDidChange(scale: CGFloat)
    
    /// Informs the delegate to refetch the doodles.
    func refetchDoodles()

}

// MARK: - Default Implementation

extension CanvasControllerDelegate {

    func actionDidFinish(action: DTNewAction) {
        // Do nothing
    }

    func dispatchChanges<S: DTStroke>(type: DTActionType, strokes: [(S, Int)]) {
        // Do nothing
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        // Do nothing
    }

    func refetchDoodles() {
        // Do nothing
    }

}
