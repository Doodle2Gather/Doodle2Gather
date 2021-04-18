import UIKit

class UserViewCell: UITableViewCell {
    @IBOutlet private var userIconLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var permissionsButton: UIButton!

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
            permissionsButton.setTitle("Viewer", for: .normal)
            permissionsButton.isSelected = false
        case .editor:
            permissionsButton.setTitle("Editor", for: .selected)
            permissionsButton.isSelected = true
        case .owner:
            permissionsButton.setTitle("Owner", for: .normal)
            permissionsButton.isSelected = false
        }
    }

    @IBAction private func didTapPermissions(_ sender: UIButton) {
    }
}
