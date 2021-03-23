import UIKit

/// An interface for a controller that manages the canvas.
/// This abstracts away all canvas-level operations.
protocol CanvasController {

    /// Delegate that will be notified when an action is performed.
    var delegate: CanvasControllerDelegate? { get set }

    /// Dispatches an action that will update the canvas accordingly.
    func dispatchAction(_ action: DTAction)

    /// Loads a given `DTDoodle`.
    func loadDoodle<D: DTDoodle>(_ doodle: D)

    /// Clears the canvas.
    func clearDoodle()

    /// Sets the current tool to the eraser tool.
    func setEraserTool()

    /// Sets the current tool to the pen tool.
    func setPenTool()

    /// Sets the current tool to the pencil tool.
    func setPencilTool()

    /// Sets the current tool to the marker tool.
    func setMarkerTool()

    /// Sets the current color used for doodling.
    func setColor(_ color: UIColor)

    /// Sets the size of the brush.
    func setSize(_ size: Float)

}
