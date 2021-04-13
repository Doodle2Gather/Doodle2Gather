import UIKit

enum CreateDocumentStatus {
    case success
    case duplicatedName
}

class NewDocumentViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!

    var didCreateDocumentCallback: ((Room) -> Void)?
    var checkDocumentNameCallback: ((String) -> CreateDocumentStatus)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction private func didTapCreate(_ sender: Any) {
        guard let user = DTAuth.user else {
            return
        }
        guard let nameCallback = checkDocumentNameCallback else {
            return
        }
        guard let creationCallback = didCreateDocumentCallback else {
            return
        }
        guard let title = titleTextField.text else {
            return
        }
        guard !title.isEmpty else {
            return
        }
        if nameCallback(title) == .duplicatedName {
            return
        }
        DTApi.createRoom(name: title, user: user.uid) { room in
            creationCallback(room)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
