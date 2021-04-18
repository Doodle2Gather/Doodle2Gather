import UIKit

class DocumentPreviewCell: UICollectionViewCell {
    @IBOutlet private var roomNameLabel: UILabel!
    @IBOutlet private var preview: UIImageView!

    private var name: String = "" {
        didSet {
            roomNameLabel.text = name
        }
    }

    func setName(_ name: String) {
        self.name = name
    }

    func setImage(_ image: UIImage) {
        print("setting!")
        print(image)
        self.preview.image = image
    }
}
