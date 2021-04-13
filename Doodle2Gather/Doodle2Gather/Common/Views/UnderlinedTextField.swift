import UIKit

/// Textfield subclass that only has a bottom border.
class UnderlinedTextField: UITextField {

    private let defaultUnderlineColor = UIColor.black
    private let bottomLine = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        borderStyle = .none
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = defaultUnderlineColor

        self.addSubview(bottomLine)
        bottomLine.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 1).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    func setUnderlineColor(color: UIColor = .red) {
        bottomLine.backgroundColor = color
    }

    func setDefaultUnderlineColor() {
        bottomLine.backgroundColor = defaultUnderlineColor
    }

}
