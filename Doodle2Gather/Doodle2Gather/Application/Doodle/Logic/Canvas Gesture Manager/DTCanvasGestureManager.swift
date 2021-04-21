import PencilKit

/// Sets up the canvas and responds to various gestures performed to it.
/// Also helps with the set-up of additional advanced gestures.
class DTCanvasGestureManager: NSObject, CanvasGestureManager {

    var canEdit = true {
        didSet {
            if canEdit {
                setMainTool(currentMainTool)
            } else {
                removeAllGestureRecognizers()
            }
        }
    }

    /// The view that the gesture manager is managing.
    var canvas = PKCanvasView() {
        didSet {
            initialiseDefaultProperties()
        }
    }
    var strokeWrappers = [DTStrokeWrapper]()

    // Tracks the tools being used
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
    var didStartCorrectly = false
    var textTapGestureRecognizer = UITapGestureRecognizer()

    /// Contains augmentors that will be used to augment the strokes.
    var augmentors = [String: StrokeAugmentor]()
    var isSelfUpdate = false

    weak var delegate: CanvasGestureManagerDelegate?

    /// Constants used in CanvasManager specifically.
    enum Constants {
        static let canvasSize = CGSize(width: 1_000_000, height: 1_000_000)
        static let detectionKey = "shapeDetection"
        static let pressureKey = "shapePressure"
    }

    /// Creates a canvas manager with a default blank canvas view.
    override init() {
        super.init()
        initialiseDefaultProperties()
        createGestureRecognizers()
    }

    /// Creates a canvas manager with a given canvas view.
    init(canvas: PKCanvasView) {
        super.init()
        self.canvas = canvas
        initialiseDefaultProperties()
        createGestureRecognizers()
    }

    /// Initialises this canvas view with the default properties.
    ///
    /// - Note: Key things performed are:
    ///   - Set zoom limitations.
    ///   - Hide scroll indicators.
    ///   - Disable auto constraints.
    ///   - Allow any input i.e. finger to be drawing input.
    ///   - Sets self as canvas delegate.
    private func initialiseDefaultProperties() {
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

    /// Creates and sets up the gesture recognizers for subsequent use.
    /// This is to reduce time and space used to recreate the recognizers
    /// every time when needed.
    private func createGestureRecognizers() {
        shapeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleShapeTap(_:)))
        selectTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectTap(_:)))
        selectPanGestureRecognizer = InitialPanGestureRecognizer(target: self, action: #selector(handleSelectPan(_:)))
        textTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextTap(_:)))
    }

}

// MARK: - Gesture Management

extension DTCanvasGestureManager: PKCanvasViewDelegate {

    /// Tells the delegate that the contents of the current drawing changed.
    ///
    /// This method is called by `canvas` when a change has been detected
    /// as a result of some gesture.
    ///
    ///
    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isSelfUpdate {
            return
        }

        let actionType = currentSelectedIndex != -1 ? .modify : currentActionType
        var drawing = canvas.drawing

        if currentMainTool == .drawing && !drawing.dtStrokes.isEmpty,
           var stroke = drawing.dtStrokes.last {
            let count = drawing.dtStrokes.count

            for augmentor in augmentors.values {
                stroke = augmentor.augmentStroke(stroke)
            }

            drawing.dtStrokes[count - 1] = stroke
        }

        delegate?.canvasViewDidChange(type: actionType, newDoodle: drawing)
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
        removeAllGestureRecognizers()
        canvas.drawingGestureRecognizer.isEnabled = true
    }

    func activateShapesGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(shapeTapGestureRecognizer)
    }

    func activateTextGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(textTapGestureRecognizer)
    }

    func activateSelectGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(selectTapGestureRecognizer)
    }

    func removeAllGestureRecognizers() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
        canvas.removeGestureRecognizer(textTapGestureRecognizer)
        canvas.removeGestureRecognizer(selectTapGestureRecognizer)
        canvas.removeGestureRecognizer(selectPanGestureRecognizer)
        unselectStroke()
    }

    @objc
    func handleShapeTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))

        switch currentShapeTool {
        case .circle:
            canvas.drawing.dtStrokes.append(shapeCreator.createCircle(center: location))
        case .square:
            canvas.drawing.dtStrokes.append(shapeCreator.createSquare(center: location))
        case .triangle:
            canvas.drawing.dtStrokes.append(shapeCreator.createTriangle(center: location))
        case .star:
            canvas.drawing.dtStrokes.append(shapeCreator.createStar(center: location))
        }

    }

    @objc
    func handleSelectTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))
        let strokesReversed: [PKStroke] = canvas.drawing.dtStrokes.reversed()
        let wrappers = strokeWrappers.reversed()
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
            if stroke.points.contains(where: { $0.location.isCloseTo(location, within: 30) }) {
                selectedIndex = canvas.drawing.dtStrokes.count - 1 - currentIndex
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
        guard var startingPoint = gesture.initialTouchLocation, currentSelectedIndex != -1,
              currentSelectedIndex < canvas.drawing.dtStrokes.count else {
            didStartCorrectly = false
            return
        }
        var stroke = canvas.drawing.dtStrokes[currentSelectedIndex]
        let translation = translatePoint(gesture.translation(in: canvas))
        startingPoint = translatePoint(startingPoint)

        guard let pointsFrame = stroke.pointsFrame else {
            didStartCorrectly = false
            return
        }

        if gesture.state == .began {
            didStartCorrectly = pointsFrame.contains(startingPoint)
        }

        if !didStartCorrectly || (translation.x * translation.x) + (translation.y * translation.y) < 3_000 {
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

        canvas.drawing.dtStrokes[currentSelectedIndex] = stroke

        if gesture.state == .ended {
            didStartCorrectly = false
        }
    }

    @objc
    func handleTextTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))

        let textBox = UITextField(frame: CGRect(x: location.x, y: location.y, width: 100, height: 50))
        textBox.text = "Hello world"
        print(textBox)
        canvas.addSubview(textBox)

        let leftConstraint = textBox.leadingAnchor.constraint(equalTo: canvas.leadingAnchor)
        leftConstraint.constant = location.x
        leftConstraint.isActive = true

        let topConstraint = textBox.topAnchor.constraint(equalTo: canvas.topAnchor)
        topConstraint.constant = location.y
        topConstraint.isActive = true

        textBox.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textBox.widthAnchor.constraint(equalToConstant: 100).isActive = true

        print("added")
        print(canvas.subviews)
    }

    func selectStroke(index: Int) {
        delegate?.setCanvasIsEditing(true)
        currentSelectedIndex = index
        isSelfUpdate = true
        let originalColor = canvas.drawing.dtStrokes[index].color
        canvas.drawing.dtStrokes[index].setIsSelected(true)
        delegate?.strokeDidSelect(color: originalColor)
        canvas.addGestureRecognizer(selectPanGestureRecognizer)
    }

    func unselectStroke() {
        if currentSelectedIndex == -1 {
            return
        }
        isSelfUpdate = false
        delegate?.setCanvasIsEditing(false)
        canvas.drawing.dtStrokes[currentSelectedIndex].setIsSelected(false)
        currentSelectedIndex = -1
        delegate?.strokeDidUnselect()
        canvas.removeGestureRecognizer(selectPanGestureRecognizer)
    }

    func translatePoint(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / canvas.zoomScale, y: point.y / canvas.zoomScale)
    }

}
