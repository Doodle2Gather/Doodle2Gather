import PencilKit
import DTFrontendLibrary
import DTSharedLibrary

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Paginated doodles
    var doodles = [PKDrawing]()
    /// Main canvas view that we will work with.
    var canvasView = PKCanvasView()
    /// Doodle that will be injected into this controller.
    var currentDoodle = PKDrawing()
    var currentDoodleIndex = 0 {
        didSet {
            doodles[oldValue] = currentDoodle
            currentDoodle = doodles[currentDoodleIndex]
            canvasView.drawing = currentDoodle
        }
    }
    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?
    private let shapeDetector: ShapeDetector = BestFitShapeDetector()
    private var actionQueue = DTActionQueue()

    /// Tracks whether a initial scroll to offset has already been done.
    private var hasScrolledToInitialOffset = false
    /// Tracks the tools being used
    private var currentMainTool = MainTools.drawing
    private var currentDrawingTool = DrawingTools.pen
    private var isSelfUpdate = false
    private var isDoodling = false

    private var currentActionType: DTActionType {
        switch currentMainTool {
        case .drawing:
            return .add
        case .eraser:
            return .remove
        case .cursor:
            return .modify
        default:
            return .unknown
        }
    }

    /// Constants used in DTCanvasViewController specifically.
    enum Constants {
        static let canvasSize = CGSize(width: 1_000_000, height: 1_000_000)
    }

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if doodles.isEmpty {
            doodles.append(PKDrawing())
        }
        currentDoodleIndex = min(currentDoodleIndex, doodles.count - 1)
        currentDoodle = doodles[currentDoodleIndex]

        addCanvasView()
        canvasView.delegate = self
        canvasView.drawing = currentDoodle
        canvasView.contentSize = Constants.canvasSize
        canvasView.setWidth(CGFloat(UIConstants.defaultPenWidth))

        actionQueue.delegate = self
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

    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isSelfUpdate {
            return
        }

        if !actionQueue.isEmpty {
            dispatchCachedActions()
        }

        let newStrokes = canvas.drawing.dtStrokes
        let oldStrokes = currentDoodle.dtStrokes

        switch currentActionType {
        case .add:
            createAndDispatchAddAction(newStrokes: newStrokes, oldStrokes: oldStrokes, canvas: canvas)
        case .remove:
            createAndDispatchRemoveAction(newStrokes: newStrokes, oldStrokes: oldStrokes)
        case .modify:
            createAndDispatchModifyAction(newStrokes: newStrokes, oldStrokes: oldStrokes)
        case .unknown:
            break
        }

        currentDoodle = PKDrawing(strokes: newStrokes)
        isDoodling = false
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        isDoodling = true
    }

    func dispatchCachedActions() {
        // Unload cached actions
        isSelfUpdate = true
        let cachedDrawing = canvasView.drawing
        canvasView.drawing = currentDoodle

        while let action = actionQueue.dequeueAction() {
            dispatchActionQuietly(action)
        }

        if currentActionType == .add, let stroke = cachedDrawing.strokes.last {
            canvasView.drawing.strokes.append(stroke)
        }
        isSelfUpdate = false
    }

    func createAndDispatchAddAction(newStrokes: [PKStroke], oldStrokes: [PKStroke], canvas: PKCanvasView) {
        if newStrokes.count != oldStrokes.count + 1 {
            fatalError("Invalid canvas state!")
        }

        if currentDrawingTool == .magicPen, let latestStroke = canvas.drawing.strokes.last {
            let fixedStroke = shapeDetector.processStroke(latestStroke)

            if let fixedStroke = fixedStroke {
                isSelfUpdate = true
                let strokeIndex = canvas.drawing.strokes.count - 1
                canvas.drawing.strokes[strokeIndex] = fixedStroke
                isSelfUpdate = false
            }
        }

        guard let stroke = canvas.drawing.strokes.last else {
            fatalError("Invalid canvas state!")
        }

        delegate?.dispatchChanges(type: .add, strokes: [(stroke, canvas.drawing.strokes.count - 1)])
    }

    func createAndDispatchRemoveAction(newStrokes: [PKStroke], oldStrokes: [PKStroke]) {
        if newStrokes.count > oldStrokes.count {
            fatalError("Invalid canvas state!")
        }

        let newStrokesSet = Set(newStrokes)
        var removedStrokes = [(PKStroke, Int)]()
        for (index, stroke) in oldStrokes.enumerated() {
            // Stroke has been removed
            if !newStrokesSet.contains(stroke) {
                removedStrokes.append((stroke, index))
            }
        }

        if removedStrokes.isEmpty {
            return
        }

        delegate?.dispatchChanges(type: .remove, strokes: removedStrokes)
    }

    func createAndDispatchModifyAction(newStrokes: [PKStroke], oldStrokes: [PKStroke]) {
        if newStrokes.count != oldStrokes.count {
            fatalError("Invalid canvas state!")
        }

        let newStrokesWrappers = newStrokes.map { PKStrokeHashWrapper(from: $0) }
        let oldStrokesWrappers = oldStrokes.map { PKStrokeHashWrapper(from: $0) }

        for (index, stroke) in newStrokesWrappers.enumerated() {
            let oldStroke = oldStrokesWrappers[index]
            if stroke != oldStroke {
                delegate?.dispatchChanges(type: .modify, strokes: [(oldStroke, index), (stroke, index)])
                return
            }
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.canvasZoomScaleDidChange(scale: scrollView.zoomScale)
    }

}

extension DTCanvasViewController: CanvasController {

    func dispatchAction(_ action: DTNewAction) {
        actionQueue.enqueueAction(action)
    }

    // Note: This method does not fire off an Action.
    func loadDoodles<D: DTDoodle>(_ doodles: [D]) {
        self.doodles = doodles.compactMap { PKDrawing(from: $0) }
        currentDoodleIndex = min(currentDoodleIndex, self.doodles.count - 1)
        currentDoodle = PKDrawing(from: doodles[currentDoodleIndex])
        canvasView.drawing = currentDoodle
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

extension DTCanvasViewController: DTActionQueueDelegate {

    func canDispatchAction() -> Bool {
        !isDoodling
    }

    func dispatchActionQuietly(_ action: DTNewAction) {
        do {
            let pair = action.strokes[0]
            guard let firstStroke: PKStroke = action.getStrokes()?[0] else {
                throw DTCanvasError.cannotParseStroke
            }

            switch action.type {
            case .add:
                try addPairQuietly(index: pair.index, stroke: firstStroke)
            case .remove:
                try removePairsQuietly(indices: action.strokes.map { $0.index },
                                       strokes: action.getStrokes() ?? [])
            case .modify:
                try modifyPairQuietly(index: pair.index, stroke: firstStroke)
            case .unknown:
                return
            }
        } catch {
            DTLogger.error(error.localizedDescription)
            actionQueue.clear()
            refetchDoodles()
        }
    }

    private func addPairQuietly(index: Int, stroke: PKStroke) throws {
        var doodleCopy = currentDoodle
        if doodleCopy.strokes.count != index {
            DTLogger.error("Failed to add pairs quietly")
            throw DTCanvasError.indexMismatch
        }
        doodleCopy.addStrokes([stroke])
        currentDoodle = doodleCopy
        canvasView.drawing = doodleCopy
    }

    /// Removes the given pairs quietly.
    private func removePairsQuietly(indices: [Int], strokes: [PKStroke]) throws {
        var doodleCopy = currentDoodle
        for (i, index) in indices.enumerated() {
            if index >= doodleCopy.strokes.count {
                DTLogger.error("Failed to remove pairs quietly")
                throw DTCanvasError.indexMismatch
            }
            let stroke = doodleCopy.strokes[index]

            if stroke != strokes[i] {
                DTLogger.error("Failed to remove pairs quietly")
                throw DTCanvasError.indexMismatch
            }
            doodleCopy.removeStrokes([stroke])
        }
        currentDoodle = doodleCopy
        canvasView.drawing = doodleCopy
    }

    private func modifyPairQuietly(index: Int, stroke: PKStroke) throws {
        var doodleCopy = currentDoodle
        if index >= doodleCopy.strokes.count || doodleCopy.strokes[index] != stroke {
            DTLogger.error("Failed to modify pairs quietly")
            throw DTCanvasError.indexMismatch
        }
        doodleCopy.strokes[index] = stroke
        currentDoodle = doodleCopy
        canvasView.drawing = doodleCopy
    }

    private func refetchDoodles() {
        DTLogger.event("Refetching doodles...")
        delegate?.refetchDoodles()
    }

}
