import UIKit

class ParticipantViewCell: UITableViewCell {

    var userId: String?
    var displayName: String?
    var isVideoOn: Bool = false
    var isAudioOn: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
