import UIKit
import Pikko

class DoodleViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var zoomScaleLabel: UILabel!
    @IBOutlet private var colorPickerView: UIView!
    @IBOutlet private var colorPickerButton: UIView!
    @IBOutlet private var widthSlider: UISlider!
    private var coloredCircle = CAShapeLayer()
    private var circleCenter = CGPoint()

    // Left Main Menu
    @IBOutlet private var drawButton: UIButton!
    @IBOutlet private var eraserButton: UIButton!
    @IBOutlet private var textButton: UIButton!
    @IBOutlet private var shapesButton: UIButton!
    @IBOutlet private var cursorButton: UIButton!

    // Left Auxiliary Menu
    @IBOutlet private var auxiliaryButtonsView: UIView!
    @IBOutlet private var penButton: UIButton!
    @IBOutlet private var pencilButton: UIButton!
    @IBOutlet private var highlighterButton: UIButton!
    @IBOutlet private var magicPenButton: UIButton!

    // Profile Images
    @IBOutlet private var userProfileImage: UIImageView!
    @IBOutlet private var otherProfileImageOne: UIImageView!
    @IBOutlet private var otherProfileImageTwo: UIImageView!
    @IBOutlet private var numberOfOtherUsersLabel: UILabel!

    // Controllers
    private var canvasController: CanvasController?
    private var socketController: SocketController?

    // State
    var username: String?
    var roomName: String?
    private var lastSelectedDrawingTool = DrawingTools.pen
    private var lastSelectedColor = UIColor.black
    private var lastSelectedWidths: [DrawingTools: Float] = [
        .pen: Constants.defaultPenWidth,
        .pencil: Constants.defaultPencilWidth,
        .highlighter: Constants.defaultHighlighterWidth,
        .magicPen: Constants.defaultPenWidth
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Replace this with dependency injection from AppDelegate / HomeController
        let socketController = DTWebSocketController()
        socketController.delegate = self
        self.socketController = socketController

        if let roomName = roomName {
            fileNameLabel.text = roomName
        }

        registerGestures()
        loadBorderColors()
        setUpColorWheel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        circleCenter = colorPickerButton.convert(CGPoint(x: colorPickerButton.bounds.midX,
                                                         y: colorPickerButton.bounds.midY),
                                                 to: view)

        // Set up color picker selector
        let path = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(Constants.defaultPenWidth),
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        coloredCircle = shapeLayer

        self.view.layer.addSublayer(shapeLayer)
        setWidth(Constants.defaultPenWidth)
    }

    private func registerGestures() {
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomScaleDidTap(_:)))
        zoomScaleLabel.addGestureRecognizer(zoomTap)
        let colorTap = UITapGestureRecognizer(target: self, action: #selector(colorPickerButtonDidTap(_:)))
        colorPickerButton.addGestureRecognizer(colorTap)

    }

    private func loadBorderColors() {
        colorPickerButton.layer.borderColor = UIConstants.stackGrey.cgColor
        numberOfOtherUsersLabel.layer.borderColor = UIConstants.stackGrey.cgColor
        // TODO: Replace profile picture borders with assigned colors
        userProfileImage.layer.borderColor = UIConstants.white.cgColor
        otherProfileImageOne.layer.borderColor = UIConstants.white.cgColor
        otherProfileImageTwo.layer.borderColor = UIConstants.white.cgColor
    }

    private func setUpColorWheel() {
        let pikko = Pikko(dimension: 200, setToColor: .black)

        // Set the PikkoDelegate to get notified on new color changes.
        pikko.delegate = self
        colorPickerView.addSubview(pikko)

        // Set autoconstraints.
        pikko.translatesAutoresizingMaskIntoConstraints = false
        pikko.topAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 10).isActive = true
        pikko.leadingAnchor.constraint(equalTo: colorPickerView.leadingAnchor, constant: 10).isActive = true
        pikko.trailingAnchor.constraint(equalTo: colorPickerView.trailingAnchor, constant: -10).isActive = true
        pikko.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas:
            guard let destination = segue.destination as? DTCanvasViewController else {
                return
            }
            destination.delegate = self
            // TODO: Complete injection of doodle into subcontroller
            // destination.doodle = // Inject doodle
            self.canvasController = destination
            canvasController?.setSize(5)
        default:
            return
        }
    }

    @IBAction private func exitButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - IBActions

extension DoodleViewController {

    @IBAction private func mainToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = MainTools(rawValue: sender.tag) else {
            return
        }
        unselectAllMainTools()
        auxiliaryButtonsView.isHidden = true
        sender.isSelected = true
        setDrawingTool(lastSelectedDrawingTool,
                       shouldDismiss: sender.tag != MainTools.drawingTool.rawValue)

        switch toolSelected {
        case .drawingTool:
            auxiliaryButtonsView.isHidden = false
            canvasController?.setColor(lastSelectedColor)
            // canvasController?.setSize(brushSizeSlider.value)
        case .eraserTool:
            colorPickerView.isHidden = true
            canvasController?.setEraserTool()
        case .textTool, .shapesTool, .cursorTool:
            colorPickerView.isHidden = true
            return
        }
    }

    @IBAction private func drawingToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = DrawingTools(rawValue: sender.tag) else {
            return
        }
        unselectAllDrawingTools()
        sender.isSelected = true
        setDrawingTool(toolSelected)
    }

    private func setDrawingTool(_ drawingTool: DrawingTools, shouldDismiss: Bool = false) {
        lastSelectedDrawingTool = drawingTool
        switch drawingTool {
        case .pen:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "Brush"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "Brush_Yellow"), for: .normal)
            canvasController?.setPenTool()
            setWidth(lastSelectedWidths[.pen])
        case .pencil:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "Pencil"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "Pencil_Yellow"), for: .normal)
            canvasController?.setPencilTool()
            setWidth(lastSelectedWidths[.pencil])
        case .highlighter:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "BrushAlt"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "BrushAlt_Yellow"), for: .normal)
            canvasController?.setHighlighterTool()
            setWidth(lastSelectedWidths[.highlighter])
        case .magicPen:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "MagicWand"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "MagicWand_Yellow"), for: .normal)
            setWidth(lastSelectedWidths[.pen])
            return
        }
    }

    private func setWidth(_ width: Float?) {
        var defaultWidth = Constants.defaultPenWidth
        switch lastSelectedDrawingTool {
        case .pen, .magicPen:
            widthSlider.minimumValue = Constants.minPenWidth
            widthSlider.maximumValue = Constants.maxPenWidth
        case .pencil:
            widthSlider.minimumValue = Constants.minPencilWidth
            widthSlider.maximumValue = Constants.maxPencilWidth
            defaultWidth = Constants.defaultPencilWidth
        case .highlighter:
            widthSlider.minimumValue = Constants.minHighlighterWidth
            widthSlider.maximumValue = Constants.maxHighlighterWidth
            defaultWidth = Constants.defaultHighlighterWidth
        }
        let width = max(min(width ?? defaultWidth, widthSlider.maximumValue), widthSlider.minimumValue)
        lastSelectedWidths[lastSelectedDrawingTool] = width
        canvasController?.setSize(width)
        widthSlider.value = width

        let path = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(width / 2),
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)
        coloredCircle.path = path.cgPath
    }

    @IBAction private func widthSliderDidChange(_ sender: UISlider) {
        let newWidth = sender.value
        setWidth(newWidth)
    }

    @IBAction private func opacitySliderDidChange(_ sender: UISlider) {
        let newOpacity = sender.value
        let newColor = UIColor(cgColor: coloredCircle.fillColor ?? UIColor.black.cgColor)
            .withAlphaComponent(CGFloat(newOpacity))
        coloredCircle.fillColor = newColor.cgColor
        canvasController?.setColor(newColor)
    }

    @objc
    private func zoomScaleDidTap(_ gesture: UITapGestureRecognizer) {
        canvasController?.resetZoomScale()
    }

    @objc
    private func colorPickerButtonDidTap(_ gesture: UITapGestureRecognizer) {
        colorPickerView.isHidden.toggle()
    }

    private func unselectAllMainTools() {
        drawButton.isSelected = false
        eraserButton.isSelected = false
        textButton.isSelected = false
        shapesButton.isSelected = false
        cursorButton.isSelected = false
    }

    private func unselectAllDrawingTools() {
        penButton.isSelected = false
        pencilButton.isSelected = false
        highlighterButton.isSelected = false
        magicPenButton.isSelected = false
    }

}

// MARK: - CanvasControllerDelegate

extension DoodleViewController: CanvasControllerDelegate {

    func actionDidFinish(action: DTAction) {
        socketController?.addAction(action)
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        let scale = min(UIConstants.maxZoom, max(UIConstants.minZoom, scale))
        let scalePercent = Int(scale * 100)
        zoomScaleLabel.text = "\(scalePercent)%"
    }

}

extension DoodleViewController: SocketControllerDelegate {

    func dispatchAction(_ action: DTAction) {
        canvasController?.dispatchAction(action)
    }

    func handleConflict(_ undoAction: DTAction, histories: [DTAction]) {

        for action in histories {
            canvasController?.dispatchAction(action)
        }

        canvasController?.dispatchAction(undoAction)

        for action in histories.reversed() {
            canvasController?.dispatchAction(action)
        }
    }

    func clearDrawing() {
        canvasController?.clearDoodle()
    }
}

extension DoodleViewController: PikkoDelegate {

    func writeBackColor(color: UIColor) {
        lastSelectedColor = color
        coloredCircle.fillColor = color.cgColor
        canvasController?.setColor(color)
    }

}
