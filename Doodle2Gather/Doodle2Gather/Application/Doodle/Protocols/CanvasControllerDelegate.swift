import Foundation
import CoreGraphics
import DTSharedLibrary

/// Delegate for a `CanvasController`.
protocol CanvasControllerDelegate: AnyObject {

    /// Notifies the delegate that an action has been completed and needs to be dispatched.
    func dispatchPartialAction(_ action: DTPartialAction)

    /// Informs the delegate that the zoom of the canvas has changed.
    func canvasZoomScaleDidChange(scale: CGFloat)

    /// Informs the delegate to refetch the doodles.
    func refetchDoodles()

}

// MARK: - Default Implementation

extension CanvasControllerDelegate {

    func dispatchPartialAction(_ action: DTPartialAction) {
        // Do nothing
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        // Do nothing
    }

    func refetchDoodles() {
        // Do nothing
    }

}
