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

    /// Doodle that will be injected into this controller.
    /// TODO: Look into a way to generalise this. Need to discuss this with
    /// the teaching team, because this is really not ideal.
    var doodle = PKDrawing()

    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?
    /// Reference to the (wrapper) delegate used by canvas.
    var delegateReference: DTCanvasViewDelegate?

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addCanvasView()
        delegateReference = canvasView.registerDelegate(self)
        canvasView.loadDoodle(doodle)
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
    func canvasViewDoodleDidChange(_ canvas: DTCanvasView) {
        guard let newStrokes: Set<PKStroke> = canvas.getStrokes() else {
            return
        }

        let oldStrokes = doodle.dtStrokes

        let addedStrokes = newStrokes.subtracting(oldStrokes)
        let removedStrokes = oldStrokes.subtracting(newStrokes)

        /// No change has occurred and we want to prevent unnecessary propagation.
        if addedStrokes.isEmpty && removedStrokes.isEmpty {
            return
        }

        doodle = PKDrawing(strokes: newStrokes)

        guard let action = DTAction(added: addedStrokes, removed: removedStrokes) else {
            return
        }
        delegate?.actionDidFinish(action: action)
    }

}

extension DTCanvasViewController: CanvasController {

    func dispatchAction(_ action: DTAction) {
        guard let (added, removed): (Set<PKStroke>, Set<PKStroke>) = action.getStrokes() else {
            return
        }
        var strokes = doodle.dtStrokes
        strokes.formUnion(added)
        strokes.subtract(removed)

        /// No change has occurred and we want to prevent unnecessary propagation.
        if strokes == doodle.dtStrokes {
            return
        }

        doodle = PKDrawing(strokes: strokes)
        self.canvasView.loadDoodle(doodle)
    }

    func loadDoodle<D: DTDoodle>(_ doodle: D) {
        self.doodle = PKDrawing(from: doodle)
    }

}
