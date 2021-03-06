import UIKit
import DTSharedLibrary

class InvitationViewController: UIViewController {

    /// Storyboard UI Elements
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inviteCodeField: UITextField!

    /// Delegate
    weak var delegate: InvitationDelegate?

    /// States
    var room: DTAdaptedRoom?
    var userAccesses: [DTAdaptedUserAccesses] = []
    var roomWSController: DTRoomWebSocketController?

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
        userAccesses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userAccess = userAccesses[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                       for: indexPath) as? UserViewCell else {
            fatalError("Unable to dequeue user cell from table view.")
        }
        cell.setUsername(userAccess.displayName)
        cell.setEmail(userAccess.email)
        cell.setPermissions(userAccess.canEdit ? .editor : .viewer)
        guard let currentUser = DTAuth.user?.uid else {
            fatalError("Attempted to join room without a user.")
        }
        if currentUser == room?.ownerId {
            setUpOwnerCell(cell, userAccess: userAccess)
        }

        if let ownerId = room?.ownerId {
            if ownerId == userAccess.userId {
                // Set callback to cell
                cell.setEditable(false)
                cell.setPermissions(.owner)
            }
        }

        return cell
    }

    private func setUpOwnerCell(_ cell: UserViewCell, userAccess: DTAdaptedUserAccesses) {
        cell.setEditable(true)
        cell.tapPermissionButtonCallback = { origin, source in
            let setViewerAction = UIAlertAction(title: "Viewer",
                                                style: .default,
                                                handler: { _ in
                self.roomWSController?.setUserPermissions(userToSetId: userAccess.userId,
                                                          setCanEdit: false,
                                                          setCanVideoConference: true,
                                                          setCanChat: true)

            })
            let setEditorAction = UIAlertAction(title: "Editor",
                                                style: .default,
                                                handler: { _ in
                self.roomWSController?.setUserPermissions(userToSetId: userAccess.userId,
                                                          setCanEdit: true,
                                                          setCanVideoConference: true,
                                                          setCanChat: true)
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

extension InvitationViewController: InvitationDelegate {

    /// Updates the userAccesses to the latest accesses received from server and reload the table view.
    func didUpdateUserAccesses(_ accesses: [DTAdaptedUserAccesses]) {
        userAccesses = accesses
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
