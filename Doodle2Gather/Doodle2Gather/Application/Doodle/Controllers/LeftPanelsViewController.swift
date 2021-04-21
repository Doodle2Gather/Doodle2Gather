import UIKit

class LeftPanelsViewController: UIViewController {

    // MARK: - UI Elements

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

    @IBOutlet private var colorPickerView: UIView!
    @IBOutlet private var pressureInfoView: UIView!
    @IBOutlet private var colorPickerButton: UIView!
    @IBOutlet private var strokeEditorHeightConstraint: NSLayoutConstraint!
    private var coloredCircle = CAShapeLayer()
    private var circleCenter = CGPoint()

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

    // MARK: - Controller State

    // State
    private var previousDrawingTool = DrawingTools.pen
    private var previousShapeTool = ShapeTools.circle
    private var previousSelectTool = SelectTools.all
    private var colorPicker: ColorPicker?
    weak var delegate: LeftPanelsControllerDelegate?

}

// MARK: - View Lifecycle Methods

extension LeftPanelsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let colorTap = UITapGestureRecognizer(target: self, action: #selector(colorPickerButtonDidTap(_:)))
        colorPickerButton.addGestureRecognizer(colorTap)
        colorPickerButton.layer.borderColor = UIConstants.stackGrey.cgColor
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toStrokeEditor {
            guard let destination = segue.destination as? ColorPickerViewController else {
                return
            }
            destination.delegate = self
            self.colorPicker = destination
        }
    }

}

// MARK: - IBActions & Gesture Recognizers

extension LeftPanelsViewController {

    @objc
    func colorPickerButtonDidTap(_ gesture: UITapGestureRecognizer) {
        colorPickerView.isHidden.toggle()
        if previousDrawingTool == .magicPen {
            pressureInfoView.isHidden = colorPickerView.isHidden
        }
    }

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

        delegate?.setMainTool(toolSelected)

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

    @IBAction private func drawingToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = DrawingTools(rawValue: sender.tag) else {
            return
        }
        unselectAllDrawingTools()
        sender.isSelected = true
        setDrawingTool(toolSelected)
        updatePressureView(toolSelected: toolSelected)
    }

    @IBAction private func shapeToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = ShapeTools(rawValue: sender.tag) else {
            return
        }
        unselectAllShapeTools()
        sender.isSelected = true
        setShapeTool(toolSelected)
    }

    @IBAction private func selectToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = SelectTools(rawValue: sender.tag) else {
            return
        }
        unselectAllSelectTools()
        sender.isSelected = true
        setSelectTool(toolSelected)
    }

    @IBAction private func pressureSwitchDidToggle(_ sender: UISwitch) {
        delegate?.setIsPressureSensitive(sender.isOn)
    }

}

// MARK: - Helper Methods

extension LeftPanelsViewController {

    func updatePressureView(toolSelected: DrawingTools) {
        if toolSelected == .magicPen && !colorPickerView.isHidden {
            pressureInfoView.isHidden = false
        } else {
            pressureInfoView.isHidden = true
        }
    }

    func setDrawingTool(_ drawingTool: DrawingTools, shouldDismiss: Bool = false) {
        previousDrawingTool = drawingTool
        delegate?.setDrawingTool(drawingTool)

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

        if let (width, color) = colorPicker?.setToolAndGetProperties(drawingTool) {
            widthDidChange(width)
            colorDidChange(color)
        }
    }

    func setShapeTool(_ shapeTool: ShapeTools) {
        previousShapeTool = shapeTool
        delegate?.setShapeTool(shapeTool)
    }

    func setSelectTool(_ selectTool: SelectTools) {
        previousSelectTool = selectTool
        delegate?.setSelectTool(selectTool)
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

}

// MARK: - LeftPanelsController

extension LeftPanelsViewController: LeftPanelsController {

    func strokeDidSelect(color: UIColor) {
        colorPicker?.enterEditStrokeMode(color: color)
        strokeEditorHeightConstraint.constant = 220
        colorPickerView.isHidden = false
    }

    func strokeDidUnselect() {
        colorPickerView.isHidden = true
        strokeEditorHeightConstraint.constant = 349
        colorPicker?.exitEditStrokeMode()
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
    }

}

// MARK: - StrokeEditorDelegate

extension LeftPanelsViewController: ColorPickerDelegate {

    func colorDidChange(_ color: UIColor) {
        coloredCircle.fillColor = color.cgColor
        delegate?.setColor(color)
    }

    func widthDidChange(_ width: CGFloat) {
        delegate?.setWidth(width)
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
        delegate?.setColor(newColor)
    }

}
