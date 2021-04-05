import UIKit
import Pikko

class DoodleViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var zoomScaleLabel: UILabel!
    @IBOutlet private var colorPickerView: UIView!
    @IBOutlet private var colorPickerButton: UIView!
    private var coloredCircle = CAShapeLayer()
    private var circleCenter = CGPoint()

    // Top Left Options
    @IBOutlet private var exitButton: UIButton!
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var fileInfoButton: UIButton!
    @IBOutlet private var separatorView: UIImageView!
    @IBOutlet private var inviteButton: UIButton!
    @IBOutlet private var exportButton: UIButton!

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
    private var strokeEditor: StrokeEditor?

    // State
    var username: String?
    var roomName: String?
    private var previousDrawingTool = DrawingTools.pen

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        circleCenter = colorPickerButton.convert(CGPoint(x: colorPickerButton.bounds.midX,
                                                         y: colorPickerButton.bounds.midY),
                                                 to: view)

        // Set up color picker selector
        let path = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(UIConstants.defaultPenWidth / 2),
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        coloredCircle = shapeLayer

        self.view.layer.addSublayer(shapeLayer)
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
        case SegueConstants.toStrokeEditor:
            guard let destination = segue.destination as? StrokeEditorViewController else {
                return
            }
            destination.delegate = self
            self.strokeEditor = destination
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
        coloredCircle.isHidden = true
        sender.isSelected = true
        setDrawingTool(previousDrawingTool,
                       shouldDismiss: sender.tag != MainTools.drawing.rawValue)

        canvasController?.setMainTool(toolSelected)

        switch toolSelected {
        case .drawing:
            auxiliaryButtonsView.isHidden = false
            coloredCircle.isHidden = false
        case .eraser:
            colorPickerView.isHidden = true
        case .text, .shapes, .cursor:
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

    @IBAction private func topMinimizeButtonDidTap(_ sender: UIButton) {
        exitButton.isHidden.toggle()
        fileNameLabel.isHidden.toggle()
        fileInfoButton.isHidden.toggle()
        separatorView.isHidden.toggle()
        inviteButton.isHidden.toggle()
        exportButton.isHidden.toggle()
        sender.isSelected.toggle()
    }

    private func setDrawingTool(_ drawingTool: DrawingTools, shouldDismiss: Bool = false) {
        previousDrawingTool = drawingTool
        canvasController?.setDrawingTool(drawingTool)

        switch drawingTool {
        case .pen:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "Brush"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "Brush_Yellow"), for: .normal)
        case .pencil:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "Pencil"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "Pencil_Yellow"), for: .normal)
        case .highlighter:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "BrushAlt"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "BrushAlt_Yellow"), for: .normal)
        case .magicPen:
            shouldDismiss ? drawButton.setImage(#imageLiteral(resourceName: "MagicWand"), for: .normal) : drawButton.setImage(#imageLiteral(resourceName: "MagicWand_Yellow"), for: .normal)
        }

        if let (width, color) = strokeEditor?.setToolAndGetProperties(drawingTool) {
            widthDidChange(width)
            colorDidChange(color)
        }
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

extension DoodleViewController: StrokeEditorDelegate {

    func colorDidChange(_ color: UIColor) {
        coloredCircle.fillColor = color.cgColor
        canvasController?.setColor(color)
    }

    func widthDidChange(_ width: CGFloat) {
        canvasController?.setWidth(width)
        let path = UIBezierPath(arcCenter: circleCenter, radius: width / 2,
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)
        coloredCircle.path = path.cgPath
    }

    func opacityDidChange(_ opacity: CGFloat) {
        guard let currentColor = coloredCircle.fillColor else {
            fatalError("Missing fill for colored circle!")
        }
        let newColor = UIColor(cgColor: currentColor)
            .withAlphaComponent(opacity)
        coloredCircle.fillColor = newColor.cgColor
        canvasController?.setColor(newColor)
    }

}
