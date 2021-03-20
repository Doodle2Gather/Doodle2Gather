import UIKit

/// Protocol for a canvas view used in DoodleTogether.
///
/// This view should:
/// - Capture user input, be it from Apple Pencil or fingers.
/// - Render and update a single DTDrawing (the update process is abstracted).
/// - Notify the delegate upon change of the DTDrawing.
protocol DTCanvasView where Self: UIView {

    /// Registers a delegate that will be notified when the drawing changes.
    func registerDelegate(_ delegate: DTCanvasViewDelegate)

    /// Loads a given `DTDrawing` into the canvas view.
    func loadDrawing<D: DTDrawing>(_ drawing: D)

}
