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

    var didCreateDocumentCallback: ((DTAdaptedRoom) -> Void)?
    var checkDocumentNameCallback: ((String) -> CreateDocumentStatus)?
    var joinDocumentCallback: ((DTAdaptedRoom) -> Void)?
    var homeWSController: DTHomeWebSocketController?

    private var isEditingTitle = true

    override func viewDidLoad() {
        super.viewDidLoad()
        homeWSController?.newDocDelegate = self

        addKeyboardObserver()
        isModalInPresentation = true

        titleTextField.attributedPlaceholder =
            NSAttributedString(string: "Title",
                               attributes: [NSAttributedString.Key.foregroundColor:
                                                UIColor.white.withAlphaComponent(0.5)])

        invitationCodeField.attributedPlaceholder =
            NSAttributedString(string: "Invitation code",
                               attributes: [NSAttributedString.Key.foregroundColor:
                                                UIColor.white.withAlphaComponent(0.5)])

        let invitationPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        invitationCodeField.leftView = invitationPaddingView
        invitationCodeField.leftViewMode = .always
        invitationCodeField.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        let titlePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        titleTextField.leftView = titlePaddingView
        titleTextField.leftViewMode = .always
        titleTextField.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        titleTextField.addTarget(self, action: #selector(didTapTitleTextField), for: .touchDown)
        invitationCodeField.addTarget(self, action: #selector(didTapInvitationCodeField), for: .touchDown)
    }

    // Handle change of orientation for chat box
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            UIView.animate(withDuration: 0.25) {
                self.view.frame.origin.y = 0
            }
        }
    }

    @objc
    func didTapTitleTextField(textField: UITextField) {
        isEditingTitle = true
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y = 0
        }
    }

    @objc
    func didTapInvitationCodeField(textField: UITextField) {
        isEditingTitle = false
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
        UIView.animate(withDuration: duration == 0 ? 0.25 : duration) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if isShowing {
                var offsetY: CGFloat = 0
                if strongSelf.isEditingTitle {
                    offsetY = strongSelf.titleTextField.frame.maxY - endKeyboardFrame.minY
                } else {
                    offsetY = strongSelf.view.frame.maxY - endKeyboardFrame.minY
                }
                if offsetY < 0 {
                    return
                } else {
                    strongSelf.view.frame.origin.y = -offsetY - 10
                }
            } else {
                strongSelf.view.frame.origin.y = 0
            }
        }
    }

    @IBAction private func didTapCreate(_ sender: Any) {
        guard let user = DTAuth.user else {
            return
        }
        guard let nameCallback = checkDocumentNameCallback else {
            return
        }
        guard let title = titleTextField.text else {
            return
        }
        guard !title.isEmpty else {
            return
        }
        if nameCallback(title) == .duplicatedName {
            alert(title: AlertConstants.notice,
                  message: AlertConstants.duplicatedTitle,
                  buttonStyle: .default
            )
            return
        }
        let newRoom = DTAdaptedRoom.CreateRequest(
            ownerId: user.uid, name: title
        )
        homeWSController?.createRoom(newRoom: newRoom)
    }

    @IBAction private func didTapJoin(_ sender: UIButton) {
        guard let code = invitationCodeField.text else {
            return
        }
        guard !code.isEmpty else {
            return
        }
        let codeCharactersSet = CharacterSet(charactersIn: code)
        let numbersSet = CharacterSet(charactersIn: "0123456789")
        guard codeCharactersSet.isSubset(of: numbersSet) else {
            alert(
                title: AlertConstants.notice,
                message: AlertConstants.invalidInvitationCode,
                buttonStyle: .default
            )
            return
        }
        homeWSController?.joinRoomFromInvite(inviteCode: code)
    }

    @IBAction private func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewDocumentViewController: DTNewDocumentWebSocketControllerDelegate {

    func didCreateRoom(newRoom: DTAdaptedRoom) {
        guard let creationCallback = didCreateDocumentCallback else {
            return
        }
        DTLogger.info { "New room creation successful" }
        DispatchQueue.main.async {
            creationCallback(newRoom)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func didFailToJoinRoom() {
        DispatchQueue.main.async {
            self.alert(
                title: AlertConstants.notice,
                message: AlertConstants.invitationCodeNotFound,
                buttonStyle: .default
            )
        }
    }

    func didJoinRoomFromInvite(joinedRoom: DTAdaptedRoom) {
        guard let joinCallback = joinDocumentCallback else {
            return
        }
        DispatchQueue.main.async {
          joinCallback(joinedRoom)
          self.dismiss(animated: true, completion: nil)
        }
    }

}
