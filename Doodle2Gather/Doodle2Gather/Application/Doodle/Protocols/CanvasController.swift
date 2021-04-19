import UIKit
import DTSharedLibrary

/// An interface for a controller that manages the canvas.
/// This abstracts away all canvas-level operations.
protocol CanvasController {

    /// Whether it is possible to undo or redo an action.
    var canUndo: Bool { get }
    var canRedo: Bool { get }

    /// Delegate that will be notified when an action is performed.
    var delegate: CanvasControllerDelegate? { get set }

    /// Dispatches an action that will update the canvas accordingly.
    func dispatchAction(_ action: DTAdaptedAction)

    /// Loads a given array of `DTDoodleWrapper`s.
    func loadDoodles(_ doodles: [DTDoodleWrapper])

    /// Sets the current tool to the drawing tool.
    func setDrawingTool(_ drawingTool: DrawingTools)

    /// Sets the current tool to the main tool.
    func setMainTool(_ mainTool: MainTools)

    /// Sets the current color used for doodling.
    func setColor(_ color: UIColor)

    /// Sets the width of the brush.
    func setWidth(_ width: CGFloat)

    /// Resets the zoom scale of the canvas to 100%.
    func resetZoomScale()

    /// Sets the current doodle to the one at this index.
    func setSelectedDoodle(index: Int)

    /// Gets the current doodle state.
    func getCurrentDoodles() -> [DTDoodleWrapper]

    /// Undos the latest action, if any.
    func undo()

    /// Redos the last undone action, if any.
    func redo()

}
