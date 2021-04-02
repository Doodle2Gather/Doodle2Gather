import PencilKit
import DoodlingLibrary

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Main canvas view that we will work with.
    var canvasView = PKCanvasView()
    /// Doodle that will be injected into this controller.
    var doodle = PKDrawing()
    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addCanvasView()
        canvasView.delegate = self
        canvasView.drawing = doodle

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        canvasView.addGestureRecognizer(pinch)
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
        // TODO: Load existing strokes into canvasView at this point
        view.addSubview(canvasView)
        canvasView.frame = view.frame
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
    }

}

extension DTCanvasViewController: PKCanvasViewDelegate {

    // TODO: Look into ways to generalise this method.
    // Currently depends on PencilKit.
    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        let newStrokes = canvas.drawing.dtStrokes
        let oldStrokes = doodle.dtStrokes
        let newStrokesSet = Set(newStrokes)
        let oldStrokesSet = Set(oldStrokes)

        let addedStrokes = newStrokes.filter { !oldStrokesSet.contains($0) }
        let removedStrokes = oldStrokes.filter { !newStrokesSet.contains($0) }

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
        guard let (added, removed): ([PKStroke], [PKStroke]) = action.getStrokes() else {
            return
        }
        var doodleCopy = doodle
        doodleCopy.addStrokes(added)
        doodleCopy.removeStrokes(removed)

        // No change has occurred and we want to prevent unnecessary propagation.
        if doodleCopy.dtStrokes == doodle.dtStrokes {
            return
        }

        doodle = doodleCopy // This prevents an action from firing later.
        canvasView.drawing = doodle
    }

    // Note: This method does not fire off an Action.
    func loadDoodle<D: DTDoodle>(_ doodle: D) {
        self.doodle = PKDrawing(from: doodle)
        canvasView.drawing = self.doodle
    }

    func clearDoodle() {
        canvasView.drawing = PKDrawing()
    }

    func setPenTool() {
        canvasView.setTool(.pen)
    }

    func setEraserTool() {
        canvasView.setTool(.eraser)
    }

    func setPencilTool() {
        canvasView.setTool(.pencil)
    }

    func setMarkerTool() {
        canvasView.setTool(.marker)
    }

    func setColor(_ color: UIColor) {
        canvasView.setColor(color)
    }

    func setSize(_ size: Float) {
        canvasView.setWidth(CGFloat(size))
    }

}

// MARK: - Gesture Recognisers

extension DTCanvasViewController {

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view != nil else {
            return
        }

        if gesture.state == .began || gesture.state == .changed,
           let transform = gesture.view?.transform {
            gesture.view?.transform = transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }

}
