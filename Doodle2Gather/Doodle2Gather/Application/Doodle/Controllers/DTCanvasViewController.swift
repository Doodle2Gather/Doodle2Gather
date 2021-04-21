import PencilKit
import DTSharedLibrary

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Paginated doodles. These doodles are also the source of truth.
    var doodles = [DTDoodleWrapper]()
    private var currentDoodleIndex = 0 {
        didSet {
            currentDoodle = doodles[currentDoodleIndex]
            canvasView.drawing = doodles[currentDoodleIndex].drawing
        }
    }
    private var currentDoodle = DTDoodleWrapper() {
        didSet {
            canvasManager.strokeWrappers = currentDoodle.strokes
        }
    }

    /// Main canvas view that we will work with.
    var canvasView = PKCanvasView()
    var canvasManager: CanvasGestureManager = DTCanvasGestureManager()
    var actionManager: ActionManager = DTActionManager()

    var canUndo: Bool {
        actionManager.canUndo
    }
    var canRedo: Bool {
        actionManager.canRedo
    }

    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?

    /// Tracks whether a initial scroll to offset has already been done.
    private var hasScrolledToInitialOffset = false
    /// Tracks whether an action received from peers should update the canvas.
    private var shouldUpdateCanvas = true

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if doodles.isEmpty {
            doodles.append(DTDoodleWrapper())
        }
        currentDoodleIndex = min(currentDoodleIndex, doodles.count - 1)
        addCanvasView()
        canvasView.drawing = doodles[currentDoodleIndex].drawing

        // Set up canvasManager via dependency injection
        canvasManager = DTCanvasGestureManager(canvas: canvasView)
        canvasManager.strokeWrappers = doodles[currentDoodleIndex].strokes
        canvasManager.delegate = self
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
        view.addSubview(canvasView)
        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

// MARK: - CanvasController

extension DTCanvasViewController: CanvasController {

    /// Dispatches an action from peers to the current drawing.
    func dispatchAction(_ action: DTActionProtocol) {
        let doodleId = action.doodleId
        let index = doodles.firstIndex(where: { $0.doodleId == doodleId })
        guard let safeIndex = index else {
            return
        }

        guard let newDoodle = actionManager.applyAction(action, on: doodles[safeIndex]) else {
            delegate?.refetchDoodles()
            return
        }

        doodles[safeIndex] = newDoodle

        if currentDoodleIndex == safeIndex && shouldUpdateCanvas {
            currentDoodle = newDoodle   // Setting this first prevents the next update
                                        // from firing off an action
            canvasView.drawing = newDoodle.drawing
        }
    }

    // Note: This method does not fire off any subsequent actions.
    func loadDoodles(_ doodles: [DTDoodleWrapper]) {
        self.doodles = doodles
        currentDoodleIndex = min(currentDoodleIndex, self.doodles.count - 1)
        currentDoodle = doodles[currentDoodleIndex]
        canvasView.drawing = doodles[currentDoodleIndex].drawing
    }

    func setDrawingTool(_ drawingTool: DrawingTools) {
        canvasManager.setDrawingTool(drawingTool)
    }

    func setShapeTool(_ shapeTool: ShapeTools) {
        canvasManager.setShapeTool(shapeTool)
    }

    func setSelectTool(_ selectTool: SelectTools) {
        canvasManager.setSelectTool(selectTool)
    }

    func setMainTool(_ mainTool: MainTools) {
        canvasManager.setMainTool(mainTool)
    }

    func setColor(_ color: UIColor) {
        canvasManager.setColor(color)
    }

    func setWidth(_ width: CGFloat) {
        canvasManager.setWidth(width)
    }

    func resetZoomScaleAndCenter() {
        UIView.animate(withDuration: 1) {
            self.canvasView.zoomScale = 1.0
            if let drawingFrame = self.canvasView.drawing.strokesFrame {
                let x = drawingFrame.midX - (UIScreen.main.bounds.width / 2)
                let y = drawingFrame.midY - (UIScreen.main.bounds.height / 2)
                self.canvasView.contentOffset = CGPoint(x: x, y: y)
            }
        }
    }

    func setSelectedDoodle(index: Int) {
        if index >= self.doodles.count {
            return
        }
        currentDoodleIndex = index
    }

    func getCurrentDoodles() -> [DTDoodleWrapper] {
        doodles
    }

    func getCurrentDoodle() -> DTDoodleWrapper {
        doodles[currentDoodleIndex]
    }

    func undo() {
        guard let action = actionManager.undo() else {
            return
        }
        guard let newDoodle = actionManager.applyAction(action, on: doodles[currentDoodleIndex]) else {
            return
        }
        doodles[currentDoodleIndex] = newDoodle
        currentDoodle = newDoodle
        canvasView.drawing = newDoodle.drawing
        delegate?.dispatchPartialAction(action)
    }

    func redo() {
        guard let action = actionManager.redo() else {
            return
        }
        guard let newDoodle = actionManager.applyAction(action, on: doodles[currentDoodleIndex]) else {
            return
        }
        doodles[currentDoodleIndex] = newDoodle
        currentDoodle = newDoodle
        canvasView.drawing = newDoodle.drawing
        delegate?.dispatchPartialAction(action)
    }

    func setIsPressureSensitive(_ isPressureSensitive: Bool) {
        canvasManager.setIsPressureSensitive(isPressureSensitive)
    }

    func setCanEdit(_ canEdit: Bool) {
        canvasManager.canEdit = canEdit
    }

}

// MARK: - CanvasGestureManagerDelegate

extension DTCanvasViewController: CanvasGestureManagerDelegate {

    func canvasZoomScaleDidChange(scale: CGFloat) {
        delegate?.canvasZoomScaleDidChange(scale: scale)
    }

    func canvasViewDidChange(type: DTActionType) {
        guard let action = actionManager.createAction(oldDoodle: currentDoodle,
                                                      newDoodle: canvasView.drawing,
                                                      actionType: type) else {
            // Somehow, a change was triggered without any actual change
            // We cannot update the canvas here, else we will be stuck in an infinite loop
            return
        }

        guard let translatedAction = actionManager.transformAction(action, on: doodles[currentDoodleIndex]) else {
            // Whatever changes that were made are no longer relevant
            // E.g. while the user is deleting a stroke, it was deleted by someone else
            currentDoodle = doodles[currentDoodleIndex]
            canvasView.drawing = currentDoodle.drawing
            return
        }

        guard let newDoodle = actionManager.applyAction(translatedAction, on: doodles[currentDoodleIndex]) else {
            delegate?.refetchDoodles()
            return
        }

        doodles[currentDoodleIndex] = newDoodle
        currentDoodle = newDoodle
        canvasView.drawing = newDoodle.drawing
        actionManager.addNewActionToUndo(translatedAction)
        delegate?.dispatchPartialAction(translatedAction)
    }

    func setCanvasIsEditing(_ isEditing: Bool) {
        shouldUpdateCanvas = !isEditing
    }

    func strokeDidSelect(color: UIColor) {
        delegate?.strokeDidSelect(color: color)
    }

    func strokeDidUnselect() {
        delegate?.strokeDidUnselect()
    }

}
