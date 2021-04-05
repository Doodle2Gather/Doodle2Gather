import PencilKit
import DTFrontendLibrary

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

    /// Tracks whether a initial scroll to offset has already been done.
    private var hasScrolledToInitialOffset = false
    /// Tracks the tools being used
    private var currentMainTool = MainTools.drawing
    private var currentDrawingTool = DrawingTools.pen
    private var isSelfUpdate = false

    /// Constants used in DTCanvasViewController specifically.
    enum Constants {
        static let canvasSize = CGSize(width: 1_000_000, height: 1_000_000)
    }

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addCanvasView()
        canvasView.delegate = self
        canvasView.drawing = doodle
        canvasView.contentSize = Constants.canvasSize
        canvasView.setWidth(CGFloat(UIConstants.defaultPenWidth))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToInitialOffset()
    }

    /// Scrolls to view to the center of the canvas. Only performed once.
    private func scrollToInitialOffset() {
        if hasScrolledToInitialOffset {
            return
        }
        let centerOffsetX = (canvasView.contentSize.width - canvasView.frame.width) / 2
        let centerOffsetY = (canvasView.contentSize.height - canvasView.frame.height) / 2
        canvasView.contentOffset = CGPoint(x: centerOffsetX, y: centerOffsetY)
        hasScrolledToInitialOffset = true
    }

    /// Hides the home indicator, as it will affect latency.
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    /// Configures the canvasView and adds it to the current view.
    func addCanvasView() {
        canvasView.initialiseDefaultProperties()
        // TODO: Load existing strokes into canvasView at this point
        view.addSubview(canvasView)

        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

extension DTCanvasViewController: PKCanvasViewDelegate {

    // TODO: Fix issues with erasure + build more sustainable solution.
    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isSelfUpdate {
            return
        }

        let newStrokes = canvas.drawing.dtStrokes
        let oldStrokes = doodle.dtStrokes
        let newStrokesSet = Set(newStrokes)
        let oldStrokesSet = Set(oldStrokes)

        if currentMainTool == .drawing && currentDrawingTool == .magicPen,
           let latestStroke = canvas.drawing.strokes.last {
            var shapeDetector = BestFitShapeDetector()
            let fixedStroke = shapeDetector.processStroke(latestStroke)

            if let fixedStroke = fixedStroke {
                isSelfUpdate = true
                let strokeIndex = canvas.drawing.strokes.count - 1
                canvas.drawing.strokes[strokeIndex] = fixedStroke
                isSelfUpdate = false
            }
        }

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

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.canvasZoomScaleDidChange(scale: scrollView.zoomScale)
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

    func setDrawingTool(_ drawingTool: DrawingTools) {
        currentDrawingTool = drawingTool
        switch drawingTool {
        case .pen:
            canvasView.setTool(.pen)
        case .pencil:
            canvasView.setTool(.pencil)
        case .highlighter:
            canvasView.setTool(.highlighter)
        case .magicPen:
            canvasView.setTool(.pen)
        }
    }

    func setMainTool(_ mainTool: MainTools) {
        currentMainTool = mainTool
        switch mainTool {
        case .drawing:
            setDrawingTool(currentDrawingTool)
        case .eraser:
            canvasView.setTool(.eraser)
        case .cursor:
            canvasView.setTool(.lasso)
        case .shapes, .text:
            // TODO: Add handling for these two
            break
        }
    }

    func setColor(_ color: UIColor) {
        canvasView.setColor(color)
    }

    func setWidth(_ width: CGFloat) {
        canvasView.setWidth(width)
    }

    func resetZoomScale() {
        canvasView.zoomScale = 1.0
    }

}
