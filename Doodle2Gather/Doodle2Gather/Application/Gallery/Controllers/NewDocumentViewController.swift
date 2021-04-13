import UIKit
import DTSharedLibrary

enum CreateDocumentStatus {
    case success
    case duplicatedName
}

class NewDocumentViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var invitationCodeField: UITextField!
    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var separator: UIView!
    @IBOutlet private var joinDocumentLabel: UILabel!
    @IBOutlet private var newDocumentLabel: UILabel!

    var didCreateDocumentCallback: ((Room) -> Void)?
    var checkDocumentNameCallback: ((String) -> CreateDocumentStatus)?
    var joinDocumentCallback: ((Room) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardObserver()
        isModalInPresentation = true
    }

    // Handle change of orientation for chat box
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            self.view.frame.origin.y = 0
        }
    }

    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    // Handle keyboard blocking input area
    @objc
    func keyboardFrameWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let endKeyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }

        let endKeyboardFrame = endKeyboardFrameValue.cgRectValue
        let duration = durationValue.doubleValue

        let isShowing: Bool = endKeyboardFrame.maxY
            > UIScreen.main.bounds.height ? false : true
        UIView.animate(withDuration: duration) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if isShowing {
                let offsetY = strongSelf.view.frame.maxY - endKeyboardFrame.minY
                if offsetY < 0 {
                    return
                } else {
                    strongSelf.view.frame.origin.y = -offsetY - 10
                }
            } else {
                strongSelf.view.frame.origin.y = 0
            }
            strongSelf.view.layoutIfNeeded()
        }
    }

    @IBAction private func didTapCreate(_ sender: Any) {
        guard let user = DTAuth.user else {
            return
        }
        guard let nameCallback = checkDocumentNameCallback else {
            return
        }
        print("World")
        guard let creationCallback = didCreateDocumentCallback else {
            return
        }
        guard let title = titleTextField.text else {
            return
        }
        print("Jesus")
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
