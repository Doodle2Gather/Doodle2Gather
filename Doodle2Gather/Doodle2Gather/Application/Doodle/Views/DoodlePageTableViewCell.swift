import UIKit

class DoodlePageTableViewCell: UITableViewCell {

    weak var delegate: DoodlePageCellDelegate?
    var index: Int = 0

    @IBOutlet private var widthConstraint: NSLayoutConstraint!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var pageNameLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIConstants.stackGrey
                textLabel?.textColor = UIConstants.white
                widthConstraint.constant = 130
                editButton.isSelected = true
            } else {
                backgroundColor = UIColor.clear
                textLabel?.textColor = UIConstants.stackGrey
                widthConstraint.constant = 110
                editButton.isSelected = false
            }
        }
    }

    func setName(_ name: String) {
        pageNameLabel.text = name
    }

    func setImage(_ image: UIImage) {
        previewImage.image = image
    }

    @IBAction private func editButtonDidTap(_ sender: UIButton) {
        delegate?.buttonDidTap(index: index)
    }
}
