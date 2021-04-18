import UIKit

class UserViewCell: UITableViewCell {
    @IBOutlet private var userIconLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        userIconLabel.layer.masksToBounds = true
        userIconLabel.layer.borderColor = UIConstants.stackGrey.cgColor
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

    @IBAction private func didTapPermissions(_ sender: UIButton) {
    }
}
