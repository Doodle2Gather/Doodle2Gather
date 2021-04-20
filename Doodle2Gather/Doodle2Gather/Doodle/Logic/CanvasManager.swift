import PencilKit

/// Sets up the canvas and responds to various gestures performed to it.
/// Also helps with the set-up of additional advanced gestures.
class CanvasManager: NSObject {

    var canvas = PKCanvasView() {
        didSet {
            initialiseDefaultProperties()
        }
    }

    /// Tracks the tools being used
    var currentMainTool = MainTools.drawing
    var currentDrawingTool = DrawingTools.pen
    var currentShapeTool = ShapeTools.circle

    /// Contains augmentors that will be used to augment the strokes.
    var augmentors = [String: StrokeAugmentor]()
    var isAugmenting = false

    weak var delegate: CanvasManagerDelegate?

    /// Constants used in CanvasManager specifically.
    enum Constants {
        static let canvasSize = CGSize(width: 1_000_000, height: 1_000_000)
        static let detectionKey = "shapeDetection"
        static let pressureKey = "shapePressure"
    }

    /// Creates a canvas manager.
    override init() {
        super.init()
        initialiseDefaultProperties()
    }

    /// Creates a canvas manager.
    init(canvas: PKCanvasView) {
        super.init()
        self.canvas = canvas
        initialiseDefaultProperties()
    }

    /// Initialises this canvas view with the default properties.
    ///
    /// Key things done are:
    /// - Set zoom limitations
    /// - Hide scroll indicators
    /// - Disable auto constraints
    /// - Allow any input i.e. finger to be drawing input.
    func initialiseDefaultProperties() {
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.minimumZoomScale = UIConstants.minZoom
        canvas.maximumZoomScale = UIConstants.maxZoom
        canvas.zoomScale = UIConstants.currentZoom
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.drawingPolicy = .anyInput
        canvas.contentSize = Constants.canvasSize

        canvas.delegate = self
        setWidth(CGFloat(UIConstants.defaultPenWidth))
    }

    func activateDrawingGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = true
    }

    func activateShapesGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = false
    }

    func activateTextGestureRecognizer() {
        // TODO: Implement this
    }

    func activateSelectGestureRecognizer() {
        // TODO: Implement this
    }

}

// MARK: - Gesture Management

extension CanvasManager: PKCanvasViewDelegate {

    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isAugmenting {
            return
        }

        if currentMainTool == .drawing && !canvas.drawing.strokes.isEmpty,
           var stroke = canvas.drawing.strokes.last {
            let count = canvas.drawing.strokes.count

            for augmentor in augmentors.values {
                stroke = augmentor.augmentStroke(stroke)
            }

            isAugmenting = true
            canvas.drawing.strokes[count - 1] = stroke
            isAugmenting = false
        }

        delegate?.canvasViewDidChange(type: currentActionType)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.canvasZoomScaleDidChange(scale: scrollView.zoomScale)
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        delegate?.setCanvasIsEditing(true)
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        delegate?.setCanvasIsEditing(false)
    }

}
