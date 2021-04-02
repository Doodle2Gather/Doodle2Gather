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
    /// Point of contact for pinch-based zooming
    var pinchPoint = CGPoint()
    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?

    enum Constants {
        static let maxScale: CGFloat = 2.0
        static let minScale: CGFloat = 0.5
        static let bufferSize: CGFloat = 200
    }

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

        // TODO: Move current view to center of existing doodle.
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

        if gesture.state == .began {
            pinchPoint = gesture.location(in: gesture.view)
        }

        if gesture.state == .changed, let transform = gesture.view?.transform {
            let currentScale = transform.a
            var newScale = gesture.scale
            newScale = min(newScale, Constants.maxScale / currentScale)
            newScale = max(newScale, Constants.minScale / currentScale)

            let point = gesture.location(in: gesture.view)
            var dx = point.x - pinchPoint.x
            var dy = point.y - pinchPoint.y

            if let strokesFrame = canvasView.drawing.strokesFrame {
                let convertedFrame = self.view.convert(strokesFrame, from: canvasView)
                let bufferSize = Constants.bufferSize
                let center = self.view.center
                let maxNewX = center.x + bufferSize
                let maxNewY = center.y + bufferSize
                let minNewX = center.x - bufferSize
                let minNewY = center.y - bufferSize

                if convertedFrame.minX + dx > maxNewX {
                    dx = maxNewX - convertedFrame.minX
                }
                if convertedFrame.maxX + dx < minNewX {
                    dx = minNewX - convertedFrame.maxX
                }
                if convertedFrame.minY + dy > maxNewY {
                    dy = maxNewY - convertedFrame.minY
                }
                if convertedFrame.maxY + dy < minNewY {
                    dy = minNewY - convertedFrame.maxY
                }
            }

            var newTransform = transform.translatedBy(x: dx, y: dy)
            newTransform = newTransform.scaledBy(x: newScale, y: newScale)

            gesture.view?.transform = newTransform
            gesture.scale = 1
        }
    }

}
