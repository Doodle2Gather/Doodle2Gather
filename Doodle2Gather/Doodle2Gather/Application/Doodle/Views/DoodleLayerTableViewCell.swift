import UIKit

class DoodleLayerTableViewCell: UITableViewCell {

    weak var delegate: DoodleLayerCellDelegate?
    var index: Int = 0

    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var layerNameLabel: UILabel!
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIConstants.stackGrey
                textLabel?.textColor = UIConstants.white
            } else {
                backgroundColor = UIColor.clear
                textLabel?.textColor = UIConstants.stackGrey
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setName(_ name: String) {
        layerNameLabel.text = name
    }

    func setImage(_ image: UIImage) {
        previewImage.image = image
    }

    @IBAction private func editButtonDidTap(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        sender.isSelected = true
    }
}
