import UIKit

class DocumentPreviewCell: UICollectionViewCell {
    @IBOutlet private var roomNameLabel: UILabel!

    private var name: String = "" {
        didSet {
            roomNameLabel.text = name
        }
    }

    func setName(_ name: String) {
        self.name = name
    }
}
