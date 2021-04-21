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
    var currentSelectedIndex = Constants.unselectedIndex
    var selectPanGestureRecognizer = InitialPanGestureRecognizer()
    var didStartCorrectly = false
    var isSelfUpdate = false // Guards against updates from panning

    /// Contains augmentors that will be used to augment the strokes.
    var augmentors = [String: StrokeAugmentor]()

    weak var delegate: CanvasGestureManagerDelegate?

    /// Constants used in CanvasManager specifically.
    enum Constants {
        static let canvasSize = CGSize(width: 1_000_000, height: 1_000_000)
        static let detectionKey = "shapeDetection"
        static let pressureKey = "shapePressure"
        static let tapRadius: CGFloat = 30
        static let panMinDistance: CGFloat = 3_000
        static let unselectedIndex: Int = -1
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
    }

}

// MARK: - Gesture Management

extension DTCanvasGestureManager: PKCanvasViewDelegate {

    /// Tells the delegate that the contents of the current drawing changed.
    ///
    /// This method is called by `canvas` when a change has been detected
    /// as a result of some gesture. It then further updates the
    /// `CanvasGestureManagerDelegate` of this change.
    ///
    /// Stroke augmentation is also performed at this point with relevant
    /// augmentors in the dictionary.
    func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
        if isSelfUpdate {
            return
        }

        let actionType = currentSelectedIndex != Constants.unselectedIndex ? .modify : currentActionType
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

    /// Tells the delegate that the user started a new drawing sequence with
    /// the currently selected tool.
    ///
    /// A further update is passed up to the `CanvasGestureManagerDelegate`
    /// of the usage of this tool.
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        delegate?.setCanvasIsEditing(true)
    }

    /// Tells the delegate that the user ended a new drawing sequence  with the
    /// tool they were using.
    ///
    /// A further update is passed up to the `CanvasGestureManagerDelegate`
    /// of the termination of usage of this tool.
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        delegate?.setCanvasIsEditing(false)
    }

    /// Activates the gestures related to drawing, deactivating the rest.
    func activateDrawingGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.drawingGestureRecognizer.isEnabled = true
    }

    /// Activates the gestures related to shape creation, deactivating the rest.
    func activateShapesGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(shapeTapGestureRecognizer)
    }

    /// Activates the gestures related to selection, deactivating the rest.
    func activateSelectGestureRecognizer() {
        removeAllGestureRecognizers()
        canvas.addGestureRecognizer(selectTapGestureRecognizer)
    }

    /// Helps to remove all gesture recognizers.
    func removeAllGestureRecognizers() {
        canvas.drawingGestureRecognizer.isEnabled = false
        canvas.removeGestureRecognizer(shapeTapGestureRecognizer)
        canvas.removeGestureRecognizer(selectTapGestureRecognizer)
        canvas.removeGestureRecognizer(selectPanGestureRecognizer)
        unselectStroke()
    }

    /// Recognizes a tap when a shape tool is selected, and adds the respective shape
    /// to the canvas.
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

    /// Recognizes a tap when the select tool is being used, and selects the stroke tapped,
    /// if any.
    ///
    /// If the mode used for selection is `.user`, then only the user's own strokes will be
    /// selected. Otherwise, all strokes can be selected.
    ///
    /// The topmost stroke at the tap area will be selected.
    @objc
    func handleSelectTap(_ gesture: UITapGestureRecognizer) {
        let location = translatePoint(gesture.location(in: canvas))
        let strokesReversed: [PKStroke] = canvas.drawing.dtStrokes.reversed()
        let wrappers = strokeWrappers.reversed()
        var selectedIndex = Constants.unselectedIndex
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
            if stroke.points.contains(where: { $0.location.isCloseTo(location, within: Constants.tapRadius) }) {
                selectedIndex = canvas.drawing.dtStrokes.count - 1 - currentIndex
                break
            }

            currentIndex += 1
        }

        if selectedIndex == currentSelectedIndex {
            return
        }

        if selectedIndex != currentSelectedIndex && currentSelectedIndex != Constants.unselectedIndex {
            unselectStroke()
            return
        }

        selectStroke(index: selectedIndex)
    }

    /// Recognizes a pan of the selected stroke and pans it accordingly.
    ///
    /// The pan will only occur when a stroke is selected and the start of the pan was
    /// sufficiently close to the stroke.
    ///
    /// - Important: There are performance issues with this gesture when utilised
    ///   with PencilKit. As such, the panning has been throttled accordingly.
    @objc
    func handleSelectPan(_ gesture: InitialPanGestureRecognizer) {
        guard var startingPoint = gesture.initialTouchLocation, currentSelectedIndex != Constants.unselectedIndex,
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

        if !didStartCorrectly || (translation.x * translation.x)
            + (translation.y * translation.y) < Constants.panMinDistance {
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

    /// Selects the stroke at the given index.
    func selectStroke(index: Int) {
        if index < 0 || index >= canvas.drawing.dtStrokes.count {
            return
        }
        delegate?.setCanvasIsEditing(true)
        currentSelectedIndex = index
        isSelfUpdate = true
        let originalColor = canvas.drawing.dtStrokes[index].color
        canvas.drawing.dtStrokes[index].setIsSelected(true)
        delegate?.strokeDidSelect(color: originalColor)
        canvas.addGestureRecognizer(selectPanGestureRecognizer)
    }

    /// Unselects the currently selected stroke, if any.
    func unselectStroke() {
        if currentSelectedIndex == Constants.unselectedIndex {
            return
        }
        isSelfUpdate = false
        delegate?.setCanvasIsEditing(false)
        canvas.drawing.dtStrokes[currentSelectedIndex].setIsSelected(false)
        currentSelectedIndex = Constants.unselectedIndex
        delegate?.strokeDidUnselect()
        canvas.removeGestureRecognizer(selectPanGestureRecognizer)
    }

    /// Translates the point based on the zoom scale.
    func translatePoint(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / canvas.zoomScale, y: point.y / canvas.zoomScale)
    }

}
