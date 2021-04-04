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
            if isVideoOn {
                videoButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
            } else {
                videoButton.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
            }
        }
    }

    var isAudioOn = false {
        didSet {
            if isAudioOn {
                audioButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            } else {
                audioButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
