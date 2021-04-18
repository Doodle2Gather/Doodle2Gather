import UIKit
import DTSharedLibrary

class InvitationViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inviteCodeField: UITextField!

    var room: DTAdaptedRoom?
    var existingUsers = [DTAdaptedUserAccesses]()

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
        existingUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = existingUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                 for: indexPath) as? UserViewCell
        cell?.setUsername(user.displayName)
        cell?.setEmail(user.email)

        // TODO: Set permissions here
        if user.userId == DTAuth.user?.uid {
            cell?.setPermissions(.owner)
        }

        if let ownerId = room?.ownerId, let currentUserId = DTAuth.user?.uid {
            if ownerId == currentUserId {
                // Set callback to cell
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
        }

        return cell!
    }

}

enum UserPermission {
    case viewer
    case editor
    case owner
}
