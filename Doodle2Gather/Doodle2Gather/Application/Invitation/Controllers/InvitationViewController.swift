import UIKit
import DTSharedLibrary

class InvitationViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inviteCodeField: UITextField!

    var inviteCode: String?
    var existingUsers = [DTAdaptedUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

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

// MARK: - UITableViewDelegate

extension InvitationViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource

extension InvitationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        existingUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = existingUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                 for: indexPath) as? UserViewCell
        return cell!
    }

}
