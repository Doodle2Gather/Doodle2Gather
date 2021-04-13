import UIKit

class DocumentPreviewCell: UICollectionViewCell {
    @IBOutlet private var roomNameLabel: UILabel!
    @IBOutlet var preview: UIImageView!

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
}
