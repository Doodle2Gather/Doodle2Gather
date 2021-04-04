import UIKit

class ParticipantViewCell: UITableViewCell {

    @IBOutlet private var userLabel: UIButton!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var videoButton: UIButton!
    @IBOutlet private var audioButton: UIButton!

    var userId: String?
    var displayName: String? {
        didSet {
            username.text = displayName
            guard let firstChar = displayName?.first else {
                return
            }
            userLabel.setTitle(String(firstChar), for: .normal)
        }
    }

    var isVideoOn = false {
        didSet {
            videoButton.isSelected = !isVideoOn
        }
    }

    var isAudioOn = false {
        didSet {
            audioButton.isSelected = !isAudioOn
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
