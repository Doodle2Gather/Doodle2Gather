import UIKit
import DTSharedLibrary

class DoodleViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var zoomScaleLabel: UILabel!
    @IBOutlet private var layerTableView: UIView!
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

    // Profile Labels
    @IBOutlet private var userProfileLabel: UILabel!
    @IBOutlet private var separator: UIImageView!
    @IBOutlet private var otherProfileLabelOne: UILabel!
    @IBOutlet private var otherProfileLabelTwo: UILabel!
    @IBOutlet private var numberOfOtherUsersLabel: UILabel!

    // Subview Controllers
    var canvasController: CanvasController?
    var socketController: SocketController?
    var strokeEditor: StrokeEditor?
    var layerTable: DoodleLayerTable?

    // State
    var username: String?
    var roomName: String?
    var roomId: UUID?
    var inviteCode: String?
    private var previousDrawingTool = DrawingTools.pen
    var doodles: [DTAdaptedDoodle]?
    var participants: [DTAdaptedUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Replace this with dependency injection from AppDelegate / HomeController
        let socketController = DTWebSocketController()
        socketController.roomId = roomId!
        socketController.delegate = self
        self.socketController = socketController

        if let roomName = roomName {
            fileNameLabel.text = roomName
        }

        registerGestures()
        loadBorderColors()
        updateProfileViews()
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

    deinit {
        socketController?.exitRoom()
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
        userProfileLabel.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelOne.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelTwo.layer.borderColor = UIConstants.white.cgColor
    }

    private func updateProfileViews() {
        userProfileLabel.layer.masksToBounds = true
        otherProfileLabelOne.layer.masksToBounds = true
        otherProfileLabelTwo.layer.masksToBounds = true

        guard let user = DTAuth.user else {
            DTLogger.error("Attempted to join room without a user.")
            return
        }

        if let firstChar = user.displayName.first(where: {
            !$0.isWhitespace
        }) {
            userProfileLabel.text = String(firstChar)
        } else {
            userProfileLabel.text = "-"
        }

        if participants.count <= 1 {
            separator.isHidden = true
            otherProfileLabelOne.isHidden = true
            otherProfileLabelTwo.isHidden = true
            numberOfOtherUsersLabel.isHidden = true
        } else if participants.count <= 2 {
            separator.isHidden = false
            setProfileLabel(otherProfileLabelOne, text: participants[1].displayName, index: 1)
            otherProfileLabelOne.isHidden = false
            otherProfileLabelTwo.isHidden = true
            numberOfOtherUsersLabel.isHidden = true
        } else if participants.count <= 3 {
            separator.isHidden = false
            setProfileLabel(otherProfileLabelOne, text: participants[1].displayName, index: 1)
            setProfileLabel(otherProfileLabelOne, text: participants[2].displayName, index: 2)
            otherProfileLabelOne.isHidden = false
            otherProfileLabelTwo.isHidden = false
            numberOfOtherUsersLabel.isHidden = true
        } else {
            separator.isHidden = false
            setProfileLabel(otherProfileLabelOne, text: participants[1].displayName, index: 1)
            setProfileLabel(otherProfileLabelOne, text: participants[2].displayName, index: 2)
            otherProfileLabelOne.isHidden = false
            otherProfileLabelTwo.isHidden = false
            numberOfOtherUsersLabel.isHidden = false
            numberOfOtherUsersLabel.text = "+\(participants.count - 3)"
        }

    }

    private func setProfileLabel(_ label: UILabel, text: String, index: Int) {
        if let firstChar = participants[index].displayName.first(where: {
            !$0.isWhitespace
        }) {
            label.text = String(firstChar)
        } else {
            label.text = "-"
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas, SegueConstants.toStrokeEditor, SegueConstants.toConference:
            prepareForSubviews(for: segue, sender: sender)
        case SegueConstants.toLayerTable, SegueConstants.toInvitation:
            prepareForPopUps(for: segue, sender: sender)
        default:
            return
        }
    }

    @IBAction private func exitButtonDidTap(_ sender: Any) {
        alert(title: AlertConstants.exit, message: AlertConstants.exitToMainMenu,
              buttonStyle: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
              }
        )
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

    @IBAction private func layerButtonDidTap(_ sender: UIButton) {
        layerTableView.isHidden.toggle()
        sender.isSelected.toggle()
    }

    @IBAction private func addLayerButtonDidTap(_ sender: UIButton) {
        socketController?.addDoodle()
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

extension DoodleViewController: DoodleLayerTableDelegate {

    func selectedDoodleDidChange(index: Int) {
        canvasController?.setSelectedDoodle(index: index)
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

    func refetchDoodles() {
        socketController?.refetchDoodles()
    }

}

// MARK: - SocketControllerDelegate

extension DoodleViewController: SocketControllerDelegate {

    func dispatchChanges<S>(type: DTActionType, strokes: [(S, Int)], doodleId: UUID) where S: DTStroke {
        guard let roomId = self.roomId,
              let action = DTAction(type: type, roomId: roomId, doodleId: doodleId, strokes: strokes) else {
            return
        }
        socketController?.addAction(action)
    }

    func dispatchAction(_ action: DTAction) {
        canvasController?.dispatchAction(action)
    }

    func loadDoodles(_ doodles: [DTAdaptedDoodle]) {
        canvasController?.loadDoodles(doodles)
        layerTable?.loadDoodles(doodles)
    }

    func addNewDoodle(_ doodle: DTAdaptedDoodle) {
        guard var doodles = doodles else {
            return
        }
        doodles.append(doodle)
        self.doodles = doodles
        canvasController?.loadDoodles(doodles)
        layerTable?.loadDoodles(doodles)
    }

    func removeDoodle(doodleId: UUID) {
        // TODO: Add after refactoring doodles
    }

}

// MARK: - StrokeEditorDelegate

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
