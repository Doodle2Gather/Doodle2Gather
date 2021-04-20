import PencilKit

/// Sets up the canvas and responds to various gestures performed to it.
/// Also helps with the set-up of additional advanced gestures.
class CanvasManager: NSObject {

    var canvas = PKCanvasView() {
        didSet {
            initialiseDefaultProperties()
        }
    }
    var canvasWrapper = DTDoodleWrapper()

    /// Tracks the tools being used
    var currentMainTool = MainTools.drawing
    var currentDrawingTool = DrawingTools.pen
    var currentShapeTool = ShapeTools.circle
    var currentSelectTool = SelectTools.all

    // Gesture Recognizers
    var shapeTapGestureRecognizer = UITapGestureRecognizer()
    var shapeCreator = ShapeCreator()
    var selectTapGestureRecognizer = UITapGestureRecognizer()
    var currentSelectedIndex = -1
    var selectPanGestureRecognizer = InitialPanGestureRecognizer()

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
        selectTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectTap(_:)))
        selectPanGestureRecognizer = InitialPanGestureRecognizer(target: self, action: #selector(handleSelectPan(_:)))
    }

}

// MARK: - Gesture Management

extension CanvasManager: PKCanvasViewDelegate {

    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isAugmenting {
            return
        }

        var actionType = currentActionType
        if currentSelectedIndex != -1 {
            actionType = .modify
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

        delegate?.setCanvasIsEditing(false)
        delegate?.canvasViewDidChange(type: actionType)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.canvasZoomScaleDidChange(scale: scrollView.zoomScale)
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        delegate?.setCanvasIsEditing(true)
    }

    func activateDrawingGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.drawingGestureRecognizer.isEnabled = true
    }

    func activateShapesGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(shapeTapGestureRecognizer)
    }

    func activateTextGestureRecognizer() {
        removeAllGestureRecognizers()
        // TODO: Implement this
    }

    func activateSelectGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(selectTapGestureRecognizer)
    }

    func removeAllGestureRecognizers() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
        canvas.removeGestureRecognizer(selectTapGestureRecognizer)
        unselectStroke()
    }

    @objc
    func handleShapeTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))

        switch currentShapeTool {
        case .circle:
            canvas.drawing.strokes.append(shapeCreator.createCircle(center: location))
        case .square:
            canvas.drawing.strokes.append(shapeCreator.createSquare(center: location))
        case .triangle:
            canvas.drawing.strokes.append(shapeCreator.createTriangle(center: location))
        case .star:
            canvas.drawing.strokes.append(shapeCreator.createStar(center: location))
        }

    }

    @objc
    func handleSelectTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))
        let strokesReversed: [PKStroke] = canvas.drawing.strokes.reversed()
        let wrappers = canvasWrapper.strokes.reversed()
        var selectedIndex = -1
        var currentIndex = 0

        for wrapper in wrappers {
            if wrapper.isDeleted {
                continue
            }
            if currentSelectTool == .user && wrapper.createdBy != DTAuth.user?.uid {
                currentIndex += 1
                continue
            }

            let stroke = strokesReversed[currentIndex]
            if stroke.points.contains(where: { $0.location.isCloseTo(location, within: 10) }) {
                selectedIndex = canvas.drawing.strokes.count - 1 - currentIndex
                break
            }

            currentIndex += 1
        }

        if selectedIndex == currentSelectedIndex {
            return
        }

        if selectedIndex != currentSelectedIndex && currentSelectedIndex != -1 {
            unselectStroke()
            return
        }

        selectStroke(index: selectedIndex)
    }

    @objc
    func handleSelectPan(_ gesture: InitialPanGestureRecognizer) {
        guard currentSelectedIndex != -1, currentSelectedIndex < canvas.drawing.strokes.count else {
            return
        }
        var stroke = canvas.drawing.strokes[currentSelectedIndex]

        let translation = translatePoint(gesture.translation(in: canvas))
        if (translation.x * translation.x) + (translation.y * translation.y) < 5_000 {
            return
        }
        gesture.setTranslation(.zero, in: canvas)

        for (index, point) in stroke.points.enumerated() {
            let newLocation = CGPoint(x: point.location.x + translation.x, y: point.location.y + translation.y)
            let newPoint = PKStrokePoint(location: newLocation, timeOffset: point.timeOffset, size: point.size,
                                         opacity: point.opacity, force: point.force, azimuth: point.azimuth,
                                         altitude: point.altitude)
            stroke.points[index] = newPoint
        }

        canvas.drawing.strokes[currentSelectedIndex] = stroke
    }

    func selectStroke(index: Int) {
        delegate?.setCanvasIsEditing(true)
        currentSelectedIndex = index
        isAugmenting = true
        let originalColor = canvas.drawing.strokes[index].color
        canvas.drawing.strokes[index].setIsSelected(true)
        delegate?.strokeDidSelect(color: originalColor)
        canvas.addGestureRecognizer(selectPanGestureRecognizer)
    }

    func unselectStroke() {
        if currentSelectedIndex == -1 {
            return
        }
        isAugmenting = false
        delegate?.setCanvasIsEditing(false)
        canvas.drawing.strokes[currentSelectedIndex].setIsSelected(false)
        currentSelectedIndex = -1
        delegate?.strokeDidUnselect()
        canvas.removeGestureRecognizer(selectPanGestureRecognizer)
    }

    func translatePoint(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / canvas.zoomScale, y: point.y / canvas.zoomScale)
    }

}
