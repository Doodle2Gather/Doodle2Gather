import UIKit

enum CreateDocumentStatus {
    case success
    case duplicatedName
}

class NewDocumentViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var invitationCodeField: UITextField!
    @IBOutlet private var separator: UIView!

    var didCreateDocumentCallback: ((Room) -> Void)?
    var checkDocumentNameCallback: ((String) -> CreateDocumentStatus)?
    var joinDocumentCallback: ((Room) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction private func didTapJoin(_ sender: UIButton) {
        guard let user = DTAuth.user else {
            return
        }
        guard let joinCallback = joinDocumentCallback else {
            return
        }
        guard let code = invitationCodeField.text else {
            return
        }
        guard !code.isEmpty else {
            return
        }
        DTApi.joinRoom(code: code, user: user.uid) { room in
            joinCallback(room)
        }
    }
}
