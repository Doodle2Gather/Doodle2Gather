import CoreGraphics

/// Delegate for a `CanvasController`.
protocol CanvasControllerDelegate: AnyObject {

    /// Notifies the delegate that an action has been completed.
    func actionDidFinish(action: DTAction)

    /// Dispatches the action to the canvas controller.
    func dispatchAction(_ action: DTAction)

    /// Informs the delegate that the zoom of the canvas has changed.
    func canvasZoomScaleDidChange(scale: CGFloat)

}

// MARK: - Default Implementation

extension CanvasControllerDelegate {

    func actionDidFinish(action: DTAction) {
        // Do nothing
    }

    func dispatchAction(_ action: DTAction) {
        // Do nothing
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        // Do nothing
    }

}
