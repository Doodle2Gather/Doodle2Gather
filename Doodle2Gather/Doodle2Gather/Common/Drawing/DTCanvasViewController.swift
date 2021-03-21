import UIKit
import PencilKit

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Main canvas view that we will work with.
    var canvasView: DTCanvasView = PKCanvasView()
    /// Drawing that will be injected into this controller.
    var drawing: some DTDrawing = PKDrawing()

    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?
    /// Reference to the (wrapper) delegate used by canvas.
    var delegateReference: DTCanvasViewDelegate?

    /// Sets up the canvas view and the initial drawing.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addCanvasView()
        delegateReference = canvasView.registerDelegate(self)
        canvasView.loadDrawing(drawing)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // TODO: Add zoom-related configurations, e.g. set min and max zoom.
        // TODO: After zooming, scroll view to the top.
    }

    /// Hides the home indicator, as it will affect latency.
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    func addCanvasView() {
        view.addSubview(canvasView)
        canvasView.frame = view.frame
    }

}

extension DTCanvasViewController: DTCanvasViewDelegate {

    // TODO: Look into ways to generalise this method.
    // Currently depends on PencilKit.
    func canvasViewDrawingDidChange(_ canvas: DTCanvasView) {
        guard let newStrokes: Set<PKStroke> = canvas.getStrokes(),
              let oldStrokes = drawing.dtStrokes as? Set<PKStroke> else {
            return
        }

        let addedStrokes = newStrokes.subtracting(oldStrokes)
        let removedStrokes = oldStrokes.subtracting(newStrokes)

        guard let action = DTAction(added: addedStrokes, removed: removedStrokes) else {
            return
        }
        delegate?.actionDidFinish(action: action)
    }

}

extension DTCanvasViewController: CanvasController {

    func dispatch(action: DTAction) {
        guard let (added, removed): (Set<PKStroke>, Set<PKStroke>) = action.getStrokes() else {
            return
        }
        print("dispatched \(action)")
        drawing.addStrokes(added)
        drawing.removeStrokes(removed)
    }

}
