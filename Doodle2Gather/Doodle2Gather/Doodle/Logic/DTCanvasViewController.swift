import PencilKit
import DTSharedLibrary

/// A `UIViewController` that manages a canvas and works with the
/// abstractions established in the `Drawing` directory.
///
/// It also ties in the `PencilKit` implementations, though those can be
/// easily swapped out without breaking any existing functionality.
class DTCanvasViewController: UIViewController {

    /// Paginated doodles
    var doodles = [DTDoodleWrapper]()
    private var currentDoodleIndex = 0 {
        didSet {
            doodles[oldValue] = actionManager.currentDoodle // To be safe
            actionManager.currentDoodle = doodles[currentDoodleIndex]
            canvasView.drawing = doodles[currentDoodleIndex].drawing
        }
    }

    /// Main canvas view that we will work with.
    var canvasView = PKCanvasView()
    var canvasManager = CanvasManager()
    var actionManager = ActionManager()

    /// Delegate for action dispatching.
    internal weak var delegate: CanvasControllerDelegate?

    /// Tracks whether a initial scroll to offset has already been done.
    private var hasScrolledToInitialOffset = false
    private var shouldSendAction = true

    /// Sets up the canvas view and the initial doodle.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if doodles.isEmpty {
            doodles.append(DTDoodleWrapper())
        }
        currentDoodleIndex = min(currentDoodleIndex, doodles.count - 1)
        addCanvasView()
        canvasView.drawing = doodles[currentDoodleIndex].drawing

        // Set up managers
        actionManager.currentDoodle = doodles[currentDoodleIndex]
        canvasManager.canvas = canvasView
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

extension DTCanvasViewController: CanvasController {

    // Note: This method does not fire off any subsequent actions.
    func dispatchAction(_ action: DTAction) {
        guard let doodle = actionManager.dispatchAction(action) else {
            delegate?.refetchDoodles()
            return
        }
        doodles[currentDoodleIndex] = doodle
        canvasView.drawing = doodle.drawing
    }

    // Note: This method does not fire off any subsequent actions.
    func loadDoodles(_ doodles: [DTDoodleWrapper]) {
        self.doodles = doodles
        currentDoodleIndex = min(currentDoodleIndex, self.doodles.count - 1)
        actionManager.currentDoodle = doodles[currentDoodleIndex]
        canvasView.drawing = doodles[currentDoodleIndex].drawing
    }

    func setDrawingTool(_ drawingTool: DrawingTools) {
        canvasManager.setDrawingTool(drawingTool)
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

    func resetZoomScale() {
        canvasView.zoomScale = 1.0
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

}

extension DTCanvasViewController: CanvasManagerDelegate {

    func canvasZoomScaleDidChange(scale: CGFloat) {
        delegate?.canvasZoomScaleDidChange(scale: scale)
    }

    func canvasViewDidChange(type: DTActionType) {
        if !shouldSendAction {
            return
        }
        let (tempAction, tempNewDoodle) = actionManager
            .createActionAndNewDoodle(doodle: canvasView.drawing, actionType: type)
        guard let action = tempAction, let newDoodle = tempNewDoodle else {
            return
        }
        doodles[currentDoodleIndex] = newDoodle
        delegate?.dispatchPartialAction(action)
    }

}
