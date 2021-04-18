import UIKit
import DTSharedLibrary

class UserViewCell: UITableViewCell {
    @IBOutlet private var userIconLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var permissionsButton: UIButton!

    var modifyPermissionCallback: ((String) -> UserPermission)?
    private var userId: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        userIconLabel.layer.masksToBounds = true
        userIconLabel.layer.borderColor = UIConstants.stackGrey.cgColor
        userIconLabel.textAlignment = .center
        userIconLabel.backgroundColor = generateRandomColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUsername(_ username: String) {
        usernameLabel.text = username
        if let firstChar = username.first(where: { !$0.isWhitespace }) {
            userIconLabel.text = String(firstChar)
        } else {
            userIconLabel.text = "-"
        }
    }

    func setEmail(_ email: String) {
        emailLabel.text = email
    }

    func generateRandomColor() -> UIColor {
        UIColor(
            red: .random(in: 0..<1),
            green: .random(in: 0..<1),
            blue: .random(in: 0..<1),
            alpha: 1.0
        )
    }

    func setPermissions(_ permission: UserPermission) {
        switch permission {
        case .viewer:
            permissionsButton.setTitle("Viewer", for: [.normal, .selected])
        case .editor:
            permissionsButton.setTitle("Editor", for: [.normal, .selected])
        case .owner:
            permissionsButton.setTitle("Owner", for: [.normal, .selected])
        }
    }

    func setEditable(_ editable: Bool) {
        if editable {
            permissionsButton.isSelected = true
        } else {
            permissionsButton.isSelected = false
        }
    }

    func setUserId(_ userId: String) {
        self.userId = userId
    }

    @IBAction private func didTapPermissions(_ sender: UIButton) {
        guard let callback = modifyPermissionCallback else {
            return
        }
        guard let id = userId else {
            return
        }
        let permission = callback(id)
        setPermissions(permission)
    }
}
