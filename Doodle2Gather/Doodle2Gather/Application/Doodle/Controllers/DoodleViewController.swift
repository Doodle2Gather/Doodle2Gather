import UIKit

class DoodleViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var drawButton: UIButton!
    @IBOutlet private var eraserButton: UIButton!
    @IBOutlet private var penButton: UIButton!
    @IBOutlet private var pencilButton: UIButton!
    @IBOutlet private var markerButton: UIButton!
    @IBOutlet private var auxiliaryButtonsView: UIView!
    @IBOutlet private var colorPickerButton: UIButton!
//    @IBOutlet private var brushSizeSlider: UISlider!

    // Controllers
    private var canvasController: CanvasController?
    private var socketController: SocketController?

    // Room State
    var username: String?
    var roomName: String?

    // Constants
    enum Segues {
        static let toCanvas = "ToCanvas"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Replace this with dependency injection from AppDelegate / HomeController
        let socketController = DTWebSocketController()
        socketController.delegate = self
        self.socketController = socketController

        if let roomName = roomName {
            fileNameLabel.text = roomName
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.toCanvas:
            guard let destination = segue.destination as? DTCanvasViewController else {
                return
            }
            destination.delegate = self
            // TODO: Complete injection of doodle into subcontroller
            // destination.doodle = // Inject doodle
            self.canvasController = destination
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

    @IBAction private func drawButtonDidTap(_ sender: UIButton) {
        hideAllBackgrounds()
        hideAllAuxiliaryBackgrounds()
        drawButton.backgroundColor = UIColor.systemGray6
        penButton.backgroundColor = UIColor.systemGray6
        canvasController?.setPenTool()
        canvasController?.setColor(colorPickerButton.backgroundColor ?? .black)
//        canvasController?.setSize(brushSizeSlider.value)
        auxiliaryButtonsView.isHidden = false
    }

    @IBAction private func penButtonDidTap(_ sender: UIButton) {
        hideAllAuxiliaryBackgrounds()
        penButton.backgroundColor = UIColor.systemGray6
        canvasController?.setPenTool()
    }

    @IBAction private func pencilButtonDidTap(_ sender: UIButton) {
        hideAllAuxiliaryBackgrounds()
        pencilButton.backgroundColor = UIColor.systemGray6
        canvasController?.setPencilTool()
    }

    @IBAction private func markerButtonDidTap(_ sender: UIButton) {
        hideAllAuxiliaryBackgrounds()
        markerButton.backgroundColor = UIColor.systemGray6
        canvasController?.setMarkerTool()
    }

    @IBAction private func eraserButtonDidTap(_ sender: UIButton) {
        hideAllBackgrounds()
        eraserButton.backgroundColor = UIColor.systemGray6
        canvasController?.setEraserTool()
        auxiliaryButtonsView.isHidden = true
    }

    @IBAction private func trashButtonDidTap(_ sender: UIButton) {
        canvasController?.clearDoodle()
    }

    @IBAction private func colorPickerButtonDidTap(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorPickerButton.backgroundColor ?? UIColor.black
        picker.delegate = self

        self.present(picker, animated: true, completion: nil)
    }

//    @IBAction private func sizeSliderDidChange(_ sender: UISlider) {
//        let newSize = sender.value
//        canvasController?.setSize(newSize)
//    }

    private func hideAllBackgrounds() {
        drawButton.backgroundColor = UIColor.clear
        eraserButton.backgroundColor = UIColor.clear
    }

    private func hideAllAuxiliaryBackgrounds() {
        penButton.backgroundColor = UIColor.clear
        pencilButton.backgroundColor = UIColor.clear
        markerButton.backgroundColor = UIColor.clear
    }

}

// MARK: - CanvasControllerDelegate

extension DoodleViewController: CanvasControllerDelegate {

    func actionDidFinish(action: DTAction) {
        socketController?.addAction(action)
    }

}

extension DoodleViewController: SocketControllerDelegate {

    func dispatchAction(_ action: DTAction) {
        canvasController?.dispatchAction(action)
    }

}

extension DoodleViewController: UIColorPickerViewControllerDelegate {

    /// Updates the selected color upon finishing of selection.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorPickerButton.backgroundColor = viewController.selectedColor
        canvasController?.setColor(viewController.selectedColor)
    }

    /// Updates the selected color every time a selection is made.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorPickerButton.backgroundColor = viewController.selectedColor
    }

}
