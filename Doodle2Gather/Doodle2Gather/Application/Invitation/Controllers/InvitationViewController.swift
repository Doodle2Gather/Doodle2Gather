import UIKit
import DTSharedLibrary

class InvitationViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inviteCodeField: UITextField!

    var room: DTAdaptedRoom?
    var userIcons = [UserIconData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        inviteCodeField.leftView = paddingView
        inviteCodeField.leftViewMode = .always
        inviteCodeField.addBottomBorderWithColor(color: UIConstants.stackGrey, width: 3)

        inviteCodeField.text = room?.inviteCode ?? "Unavailable"
    }

    @IBAction private func didTapCopy(_ sender: UIButton) {
        guard let code = room?.inviteCode else {
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
        userIcons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userIcon = userIcons[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                 for: indexPath) as? UserViewCell
        cell?.setUsername(userIcon.user.displayName)
        cell?.setEmail(userIcon.user.email)
        cell?.setColor(userIcon.color)

        // TODO: Set permissions here
        guard let currentUser = DTAuth.user?.uid else {
            fatalError("Attempted to join room without a user.")
        }
        if currentUser == room?.ownerId {
            cell?.setEditable(true)
            cell?.tapPermissionButtonCallback = { origin, source in
                let setViewerAction = UIAlertAction(title: "Viewer",
                                                    style: .default,
                                                    handler: { _ in
                    print("Change to viewer")
                })
                let setEditorAction = UIAlertAction(title: "Editor",
                                                    style: .default,
                                                    handler: { _ in
                    print("Change to editor")
                })
                DispatchQueue.main.async {
                    self.actionSheet(message: nil,
                                     actions: [setViewerAction, setEditorAction],
                                     origin: origin,
                                     source: source)
                }
            }
        }
        cell?.setPermissions(.editor)

        if let ownerId = room?.ownerId {
            if ownerId == userIcon.user.userId {
                // Set callback to cell
                cell?.setEditable(false)
                cell?.setPermissions(.owner)
            }
        }

        return cell!
    }

}

enum UserPermission {
    case viewer
    case editor
    case owner
}

struct UserIconData {
    let user: DTAdaptedUserAccesses
    let color: UIColor
}
