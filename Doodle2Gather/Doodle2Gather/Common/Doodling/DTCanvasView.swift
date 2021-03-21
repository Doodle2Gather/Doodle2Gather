import UIKit

/// Protocol for a canvas view used in DoodleTogether.
///
/// This view should:
/// - Capture user input, be it from Apple Pencil or fingers.
/// - Render and update a single `DTDoodle` (the update process is abstracted).
/// - Notify the delegate upon change of the `DTDoodle`.
///
/// Possible changes in the future:
/// - Combining this with `DTCanvasViewController`.
protocol DTCanvasView where Self: UIView {

    /// Registers a delegate that will be notified when the doodle changes and
    /// returns either the passed in delegate or a wrapper for that.
    ///
    /// `Important`: A reference to this returned delegate will need to be kept.
    func registerDelegate(_ delegate: DTCanvasViewDelegate) -> DTCanvasViewDelegate

    /// Loads a given `DTDoodle` into the canvas view.
    func loadDoodle<D: DTDoodle>(_ doodle: D)

    /// Gets the strokes displayed on the canvas.
    func getStrokes<S: DTStroke>() -> Set<S>?

    /// Gets the doodle displayed on the canvas.
    func getDoodle<D: DTDoodle>() -> D?

}
