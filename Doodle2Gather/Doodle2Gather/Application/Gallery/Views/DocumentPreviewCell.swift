import UIKit

class DocumentPreviewCell: UICollectionViewCell {
    @IBOutlet private var roomNameLabel: UILabel!
    @IBOutlet private var preview: UIImageView!
    @IBOutlet private var deleteButton: UIButton!

    private var name: String = "" {
        didSet {
            roomNameLabel.text = name
        }
    }

    func setName(_ name: String) {
        self.name = name
    }

    func setImage(_ image: UIImage) {
        self.preview.image = image
    }

    func setIsEditing(_ isEditing: Bool) {
        if isEditing {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
}
