import UIKit

class DoodleViewController: UIViewController {

    private var canvasController: CanvasController?

    private var wsController: WebSocketController?

    // Using `static let` in enums for constants seems to have the following advantages:
    // https://stackoverflow.com/a/61543705
    enum Segues {
        static let toCanvas = "ToCanvas"
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.toCanvas:
            guard let destination = segue.destination as? DTCanvasViewController else {
                return
            }
            destination.delegate = self
            // TODO: Complete injection of drawing into subcontroller
            // destination.drawing = // Inject drawing
            self.canvasController = destination
            self.wsController = WebSocketController(canvasController: destination)
        default:
            return
        }
    }
}

// MARK: - CanvasControllerDelegate

extension DoodleViewController: CanvasControllerDelegate {
    func actionDidFinish(action: DTAction) {
        // TODO: Dispatch this action via the network
        print("\(action)")
        wsController?.addAction(action)
    }

    // TODO: Add dispatching of actions received from network to the canvas
}
