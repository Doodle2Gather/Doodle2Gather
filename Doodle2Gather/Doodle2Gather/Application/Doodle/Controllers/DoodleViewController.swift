import UIKit

class DoodleViewController: UIViewController {

    private var canvasController: CanvasController?

    private var socketController: SocketController?

    // Using `static let` in enums for constants seems to have the following advantages:
    // https://stackoverflow.com/a/61543705
    enum Segues {
        static let toCanvas = "ToCanvas"
    }

    @IBOutlet private var fileNameLabel: UILabel!
    var username: String?
    var roomName: String?

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

}

// MARK: - IBActions

extension DoodleViewController {

    @IBAction private func trashButtonDidTap(_ sender: UIButton) {
        canvasController?.clearDoodle()
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
