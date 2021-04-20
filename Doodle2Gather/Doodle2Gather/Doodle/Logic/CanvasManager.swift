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

    // Gesture Recognizers
    var shapeTapGestureRecognizer = UITapGestureRecognizer()
    var shapeCreator = ShapeCreator()

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
        createGestureRecognizers()
    }

    /// Creates a canvas manager.
    init(canvas: PKCanvasView) {
        super.init()
        self.canvas = canvas
        initialiseDefaultProperties()
        createGestureRecognizers()
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

    func createGestureRecognizers() {
        shapeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleShapeTap(_:)))
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

    func activateDrawingGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = true
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
    }

    func activateShapesGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.addGestureRecognizer(shapeTapGestureRecognizer)
    }

    func activateTextGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
        // TODO: Implement this
    }

    func activateSelectGestureRecognizer() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
        // TODO: Implement this
    }

    @objc
    func handleShapeTap(_ gesture: UITapGestureRecognizer) {
        var location = gesture.location(in: canvas)
        location = CGPoint(x: location.x / canvas.zoomScale, y: location.y / canvas.zoomScale)

        switch currentShapeTool {
        case .circle:
            canvas.drawing.strokes.append(shapeCreator.createCircle(center: location))
        case .square:
            canvas.drawing.strokes.append(shapeCreator.createSquare(center: location))
        default:
            break
        }

    }

}
