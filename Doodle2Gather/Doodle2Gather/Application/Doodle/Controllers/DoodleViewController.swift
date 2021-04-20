// swiftlint:disable file_length
import UIKit
import DTSharedLibrary

class DoodleViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var zoomScaleLabel: UILabel!
    @IBOutlet private var layerTableView: UIView!
    @IBOutlet private var colorPickerView: UIView!
    @IBOutlet private var pressureInfoView: UIView!
    @IBOutlet private var colorPickerButton: UIView!
    @IBOutlet private var strokeEditorHeightConstraint: NSLayoutConstraint!
    private var coloredCircle = CAShapeLayer()
    private var circleCenter = CGPoint()

    // Top Left Options
    @IBOutlet private var exitButton: UIButton!
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var separatorView: UIImageView!
    @IBOutlet private var inviteButton: UIButton!
    @IBOutlet private var exportButton: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var redoButton: UIButton!

    // Left Main Menu
    @IBOutlet private var leftButtonsView: UIView!
    @IBOutlet private var drawButton: UIButton!
    @IBOutlet private var eraserButton: UIButton!
    @IBOutlet private var textButton: UIButton!
    @IBOutlet private var shapesButton: UIButton!
    @IBOutlet private var cursorButton: UIButton!

    // Drawing Tools Menu
    @IBOutlet private var drawingToolsButtonsView: UIView!
    @IBOutlet private var penButton: UIButton!
    @IBOutlet private var pencilButton: UIButton!
    @IBOutlet private var highlighterButton: UIButton!
    @IBOutlet private var magicPenButton: UIButton!

    // Shapes Menu
    @IBOutlet private var shapesButtonsView: UIView!
    @IBOutlet private var circleButton: UIButton!
    @IBOutlet private var squareButton: UIButton!
    @IBOutlet private var triangleButton: UIButton!
    @IBOutlet private var starButton: UIButton!

    // Select Menu
    @IBOutlet private var selectButtonsView: UIView!
    @IBOutlet private var selectAllButton: UIButton!
    @IBOutlet private var selectSelfButton: UIButton!

    // Profile Labels
    @IBOutlet private var userProfileLabel: UILabel!
    @IBOutlet private var separator: UIImageView!
    @IBOutlet private var otherProfileLabelOne: UILabel!
    @IBOutlet private var otherProfileLabelTwo: UILabel!
    @IBOutlet private var numberOfOtherUsersLabel: UILabel!

    // Subview Controllers
    var canvasController: CanvasController?
    var appWSController: DTWebSocketController?
    var roomWSController = DTRoomWebSocketController()
    var strokeEditor: StrokeEditor?
    var layerTable: DoodleLayerTable?
    var loadingSpinner: UIAlertController?

    // Delegates
    weak var invitationDelegate: InvitationDelegate?

    // State
    var room: DTAdaptedRoom?
    var username: String?
    var doodles: [DTDoodleWrapper]?
    var participants: [DTAdaptedUser] = []
    var userAccesses: [DTAdaptedUserAccesses] = []
    var userStates: [UserState] = []
    var userIconColors: [UIColor] = []
    private var previousDrawingTool = DrawingTools.pen
    private var previousShapeTool = ShapeTools.circle
    private var previousSelectTool = SelectTools.all

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let room = room,
              let roomId = room.roomId else {
            fatalError("Doodle VC has no injected room")
        }
        self.appWSController?.registerSubcontroller(self.roomWSController)
        self.roomWSController.roomId = roomId
        self.roomWSController.delegate = self

        self.roomWSController.joinRoom(roomId: roomId)

        fileNameLabel.text = room.name

        registerGestures()
        loadBorderColors()
        initialiseProfileColors()
        updateProfileViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        circleCenter = colorPickerButton.convert(CGPoint(x: colorPickerButton.bounds.midX,
                                                         y: colorPickerButton.bounds.midY),
                                                 to: drawingToolsButtonsView)

        // Set up color picker selector
        let path = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(UIConstants.defaultPenWidth / 2),
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        coloredCircle = shapeLayer

        self.drawingToolsButtonsView.layer.addSublayer(shapeLayer)
    }

    deinit {
        roomWSController.exitRoom()
        self.appWSController?.removeSubcontroller(self.roomWSController)
    }

    private func registerGestures() {
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomScaleDidTap(_:)))
        zoomScaleLabel.addGestureRecognizer(zoomTap)
        let colorTap = UITapGestureRecognizer(target: self, action: #selector(colorPickerButtonDidTap(_:)))
        colorPickerButton.addGestureRecognizer(colorTap)

    }

    func loadBorderColors() {
        colorPickerButton.layer.borderColor = UIConstants.stackGrey.cgColor
        numberOfOtherUsersLabel.layer.borderColor = UIConstants.stackGrey.cgColor
        userProfileLabel.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelOne.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelTwo.layer.borderColor = UIConstants.white.cgColor
    }

    func updateProfileViews() {
        userProfileLabel.layer.masksToBounds = true
        otherProfileLabelOne.layer.masksToBounds = true
        otherProfileLabelTwo.layer.masksToBounds = true
    }

    func initialiseProfileColors() {
        for _ in 0..<UIConstants.userIconColorCount {
            userIconColors.append(generateRandomColor())
        }
    }

    func updateProfileColors() {
        guard let user = DTAuth.user else {
            DTLogger.error("Attempted to join room without a user.")
            return
        }

        setProfileLabel(userProfileLabel, text: user.displayName)
        userProfileLabel.backgroundColor = userIconColors[0]

        let otherUserStates = userStates.filter({ state -> Bool in
            state.userId != user.uid
        })
        let labels: [UILabel?] = [otherProfileLabelOne, otherProfileLabelTwo, numberOfOtherUsersLabel]

        for i in 0..<labels.count {
            guard let label = labels[i] else {
                fatalError("Label is not loaded")
            }
            if i >= otherUserStates.count {
                label.isHidden = true
                continue
            }
            label.isHidden = false
            if i < labels.count - 1 {
                setProfileLabel(label, text: otherUserStates[i].displayName)
                label.backgroundColor = userIconColors[i + 1]
            }
        }

        separator.isHidden = otherUserStates.isEmpty
        if otherUserStates.count > 2 {
            numberOfOtherUsersLabel.text = "+\(userStates.count - 3)"
        }
    }

    private func setProfileLabel(_ label: UILabel, text: String) {
        if let firstChar = text.first(where: {
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

}

// MARK: - IBActions Part 1

extension DoodleViewController {

    @IBAction private func mainToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = MainTools(rawValue: sender.tag) else {
            return
        }
        unselectAllMainTools()
        drawingToolsButtonsView.isHidden = true
        shapesButtonsView.isHidden = true
        selectButtonsView.isHidden = true
        sender.isSelected = true
        setDrawingTool(previousDrawingTool, shouldDismiss: sender.tag != MainTools.drawing.rawValue)

        canvasController?.setMainTool(toolSelected)

        if toolSelected != .drawing {
            colorPickerView.isHidden = true
            pressureInfoView.isHidden = true
        }

        switch toolSelected {
        case .drawing:
            drawingToolsButtonsView.isHidden = false
        case .cursor:
            selectButtonsView.isHidden = false
        case .shapes:
            shapesButtonsView.isHidden = false
        default:
            break
        }
    }

    @IBAction private func topMinimizeButtonDidTap(_ sender: UIButton) {
        fileNameLabel.isHidden.toggle()
        separatorView.isHidden.toggle()
        inviteButton.isHidden.toggle()
        exportButton.isHidden.toggle()
        sender.isSelected.toggle()
    }

    func updatePressureView(toolSelected: DrawingTools) {
        if toolSelected == .magicPen && !colorPickerView.isHidden {
            pressureInfoView.isHidden = false
        } else {
            pressureInfoView.isHidden = true
        }
    }

    func setDrawingTool(_ drawingTool: DrawingTools, shouldDismiss: Bool = false) {
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

    func setShapeTool(_ shapeTool: ShapeTools) {
        previousShapeTool = shapeTool
        canvasController?.setShapeTool(shapeTool)
    }

    func setSelectTool(_ selectTool: SelectTools) {
        previousSelectTool = selectTool
        canvasController?.setSelectTool(selectTool)
    }

    @IBAction private func layerButtonDidTap(_ sender: UIButton) {
        if let doodles = canvasController?.getCurrentDoodles() {
            layerTable?.loadDoodles(doodles)
        }
        layerTableView.isHidden.toggle()
        sender.isSelected.toggle()
    }

    @IBAction private func exportButtonDidTap(_ sender: UIButton) {
        // TODO: Export to image for now
    }

    @objc
    func colorPickerButtonDidTap(_ gesture: UITapGestureRecognizer) {
        colorPickerView.isHidden.toggle()
        if previousDrawingTool == .magicPen {
            pressureInfoView.isHidden = colorPickerView.isHidden
        }
    }

    @objc
    private func zoomScaleDidTap(_ gesture: UITapGestureRecognizer) {
        canvasController?.resetZoomScaleAndCenter()
    }

    func unselectAllMainTools() {
        drawButton.isSelected = false
        eraserButton.isSelected = false
        textButton.isSelected = false
        shapesButton.isSelected = false
        cursorButton.isSelected = false
    }

    func unselectAllDrawingTools() {
        penButton.isSelected = false
        pencilButton.isSelected = false
        highlighterButton.isSelected = false
        magicPenButton.isSelected = false
    }

    func unselectAllShapeTools() {
        circleButton.isSelected = false
        squareButton.isSelected = false
        triangleButton.isSelected = false
        starButton.isSelected = false
    }

    func unselectAllSelectTools() {
        selectAllButton.isSelected = false
        selectSelfButton.isSelected = false
    }

    func setCanEdit(_ canEdit: Bool) {
        if canEdit {
            leftButtonsView.isHidden = false
        } else {
            leftButtonsView.isHidden = true
            drawingToolsButtonsView.isHidden = true
            shapesButtonsView.isHidden = true
            selectButtonsView.isHidden = true
            colorPickerView.isHidden = true
        }
        canvasController?.setCanEdit(canEdit)
    }

}

// MARK: - CanvasControllerDelegate

extension DoodleViewController: CanvasControllerDelegate {

    func dispatchPartialAction(_ action: DTPartialAdaptedAction) {
        guard let roomId = self.room?.roomId else {
            return
        }
        let action = DTAdaptedAction(partialAction: action, roomId: roomId)
        roomWSController.addAction(action)

        undoButton.isEnabled = canvasController?.canUndo ?? false
        redoButton.isEnabled = canvasController?.canRedo ?? false
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        let scale = min(UIConstants.maxZoom, max(UIConstants.minZoom, scale))
        let scalePercent = Int(scale * 100)
        zoomScaleLabel.text = "\(scalePercent)%"
    }

    func refetchDoodles() {
        if loadingSpinner == nil {
            loadingSpinner = self.createSpinnerView(message: "Refetching Doodles...")
        }
        roomWSController.refetchDoodles()
    }

    func strokeDidSelect(color: UIColor) {
        strokeEditor?.enterEditStrokeMode(color: color)
        strokeEditorHeightConstraint.constant = 220
        colorPickerView.isHidden = false
    }

    func strokeDidUnselect() {
        colorPickerView.isHidden = true
        strokeEditorHeightConstraint.constant = 349
        strokeEditor?.exitEditStrokeMode()
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
