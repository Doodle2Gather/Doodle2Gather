import UIKit

/// Protocol for a canvas view used in DoodleTogether.
///
/// This view should:
/// - Capture user input, be it from Apple Pencil or fingers.
/// - Render and update a single DTDrawing (the update process is abstracted).
/// - Notify the delegate upon change of the DTDrawing.
protocol DTCanvasView where Self: UIView {

    /// Registers a delegate that will be notified when the drawing changes and
    /// returns either the passed in delegate or a wrapper for that.
    ///
    /// `Important`: A reference to this returned delegate will need to be kept.
    func registerDelegate(_ delegate: DTCanvasViewDelegate) -> DTCanvasViewDelegate

    /// Loads a given `DTDrawing` into the canvas view.
    func loadDrawing<D: DTDrawing>(_ drawing: D)

    /// Gets the strokes displayed on the canvas.
    func getStrokes<S: DTStroke>() -> Set<S>?

    /// Gets the drawing displayed on the canvas.
    func getDrawing<D: DTDrawing>() -> D?

}
