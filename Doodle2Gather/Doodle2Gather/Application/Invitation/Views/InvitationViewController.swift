import UIKit

class InvitationViewController: UIViewController {

    @IBOutlet private var inviteCodeField: UITextField!

    var inviteCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        inviteCodeField.leftView = paddingView
        inviteCodeField.leftViewMode = .always
        inviteCodeField.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        inviteCodeField.text = inviteCode
    }

    @IBAction private func didTapCopy(_ sender: UIButton) {
        guard let code = inviteCode else {
            return
        }
        let pasteboard = UIPasteboard.general
        pasteboard.string = code
    }
}
