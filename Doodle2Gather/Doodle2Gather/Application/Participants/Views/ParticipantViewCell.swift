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
                videoButton.setImage(#imageLiteral(resourceName: "VideoOn_PNG"), for: .normal)
            } else {
                videoButton.setImage(#imageLiteral(resourceName: "VideoOff_Red_PNG"), for: .normal)
            }
        }
    }

    var isAudioOn = false {
        didSet {
            if isAudioOn {
                audioButton.setImage(#imageLiteral(resourceName: "SoundOn_PNG"), for: .normal)
            } else {
                audioButton.setImage(#imageLiteral(resourceName: "SoundOff_Red_PNG"), for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
