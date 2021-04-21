import UIKit
import Pikko

class ColorPickerViewController: UIViewController {

    @IBOutlet private var widthLabel: UILabel!
    @IBOutlet private var widthSlider: UISlider!
    @IBOutlet private var opacityLabel: UILabel!
    @IBOutlet private var opacitySlider: UISlider!

    weak var delegate: ColorPickerDelegate?
    private var pikko: Pikko?
    private var toolSelected: DrawingTools = .pen
    private var colorSelected: UIColor = .black
    private var widthCache: [DrawingTools: Float] = [
        .pen: UIConstants.defaultPenWidth,
        .pencil: UIConstants.defaultPencilWidth,
        .highlighter: UIConstants.defaultHighlighterWidth,
        .magicPen: UIConstants.defaultPenWidth
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let pikko = Pikko(dimension: 200, setToColor: .black)

        // Set the PikkoDelegate to get notified on new color changes.
        pikko.delegate = self
        view.addSubview(pikko)

        // Set autoconstraints.
        pikko.translatesAutoresizingMaskIntoConstraints = false
        pikko.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        pikko.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        pikko.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        pikko.heightAnchor.constraint(equalToConstant: 200).isActive = true

        self.pikko = pikko
        widthSlider.setThumbImage(#imageLiteral(resourceName: "SliderThumb"), for: .normal)
        opacitySlider.setThumbImage(#imageLiteral(resourceName: "SliderThumb"), for: .normal)
    }

    @IBAction private func widthSliderDidChange(_ sender: UISlider) {
        let newWidth = sender.value
        widthCache[toolSelected] = newWidth
        delegate?.widthDidChange(CGFloat(newWidth))
    }

    @IBAction private func opacitySliderDidChange(_ sender: UISlider) {
        let newOpacity = sender.value
        delegate?.opacityDidChange(CGFloat(newOpacity))
    }

}

extension ColorPickerViewController: PikkoDelegate {

    /// Informs the delegate that the color picked has changed.
    func writeBackColor(color: UIColor) {
        colorSelected = color
        delegate?.colorDidChange(color)
    }

}

extension ColorPickerViewController: ColorPicker {

    func setToolAndGetProperties(_ tool: DrawingTools) -> (width: CGFloat, color: UIColor) {
        toolSelected = tool

        guard let width = widthCache[tool] else {
            fatalError("Added new tool without updating default width!")
        }

        switch tool {
        case .pen, .magicPen:
            widthSlider.minimumValue = UIConstants.minPenWidth
            widthSlider.maximumValue = UIConstants.maxPenWidth
        case .pencil:
            widthSlider.minimumValue = UIConstants.minPencilWidth
            widthSlider.maximumValue = UIConstants.maxPencilWidth
        case .highlighter:
            widthSlider.minimumValue = UIConstants.minHighlighterWidth
            widthSlider.maximumValue = UIConstants.maxHighlighterWidth
        }

        widthSlider.value = width
        return (width: CGFloat(width), color: colorSelected)
    }

    func enterEditStrokeMode(color: UIColor) {
        widthLabel.isHidden = true
        widthSlider.isHidden = true
        opacityLabel.isHidden = true
        opacitySlider.isHidden = true
        pikko?.setColor(color)
    }

    func exitEditStrokeMode() {
        widthLabel.isHidden = false
        widthSlider.isHidden = false
        opacityLabel.isHidden = false
        opacitySlider.isHidden = false
    }

}
