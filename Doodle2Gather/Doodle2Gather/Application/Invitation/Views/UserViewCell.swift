import UIKit
import DTSharedLibrary

class UserViewCell: UITableViewCell {
    @IBOutlet private var userIconLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var permissionsButton: UIButton!

    var tapPermissionButtonCallback: ((CGPoint, UIView) -> Void)?
    var modifyPermissionCallback: ((String, UserPermission) -> UserPermission)?
    private var userId: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        userIconLabel.layer.masksToBounds = true
        userIconLabel.layer.borderColor = UIConstants.stackGrey.cgColor
        userIconLabel.textAlignment = .center
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

    func setColor(_ color: UIColor) {
        userIconLabel.backgroundColor = color
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
        guard let tapCallback = tapPermissionButtonCallback else {
            return
        }
        let origin = CGPoint(x: sender.frame.midX, y: sender.frame.midY)
        tapCallback(origin, self)
    }
}
