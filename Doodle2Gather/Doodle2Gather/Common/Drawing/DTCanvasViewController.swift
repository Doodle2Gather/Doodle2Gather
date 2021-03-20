import UIKit
import PencilKit

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Main canvas view that we will work with.
    private var canvasView: DTCanvasView = PKCanvasView()
    /// Drawing that will be injected into this controller.
    private var drawing: some DTDrawing = PKDrawing()

    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?

    /// Sets up the canvas view and the initial drawing.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addCanvasView()
        canvasView.registerDelegate(self)
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

    func canvasViewDrawingDidChange(_: DTCanvasView) {
        // TODO: Create action and update delegate
        print("TODO")
    }

}

extension DTCanvasViewController: CanvasController {

    func dispatch(action: DTAction) {
        // TODO: Propagate action to canvasView's drawing.
        print("TODO")
    }

}
