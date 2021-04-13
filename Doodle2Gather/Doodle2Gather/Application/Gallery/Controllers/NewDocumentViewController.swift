import UIKit
import DTSharedLibrary

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
        let newRoom = DTAdaptedRoom.CreateRequest(
            ownerId: user.uid, name: title
        )
        DTApi.createRoom(newRoom) { result in
            switch result {
            case .failure(let error):
                DTLogger.error(error.localizedDescription)
            case .success(.some(let room)):
                guard let createdRoom = Room(room: room) else {
                    return
                }
              DispatchQueue.main.async {
                creationCallback(createdRoom)
                self.dismiss(animated: true, completion: nil)
              }
            case .success(.none):
                break
            }
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
        DTApi.joinRoomFromInvite(joinRoomRequest: DTJoinRoomMessage(userId: user.uid,
                                                                    roomId: nil,
                                                                    inviteCode: code)) { result in
            switch result {
            case .failure(let error):
                print(error)
                DTLogger.error(error.localizedDescription)
            case .success(.some(let room)):
                guard let createdRoom = Room(room: room) else {
                    return
                }
              DispatchQueue.main.async {
                joinCallback(createdRoom)
                self.dismiss(animated: true, completion: nil)
              }
            case .success(.none):
                break
            }
        }
    }

    @IBAction private func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
