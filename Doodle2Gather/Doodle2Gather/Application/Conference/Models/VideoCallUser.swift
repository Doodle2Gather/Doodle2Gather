import UIKit

class VideoCallUser {
    var uid: UInt
    var userId: String
    var overlay: UIView
    var nameplate: UILabel
    var isPlateActive = false

    init(uid: UInt, userId: String, overlay: UIView, nameplate: UILabel) {
        self.uid = uid
        self.userId = userId
        self.overlay = overlay
        self.nameplate = nameplate
    }
}

extension VideoCallUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }

}

extension VideoCallUser: Equatable {
    static func == (lhs: VideoCallUser, rhs: VideoCallUser) -> Bool {
        lhs.userId == rhs.userId
    }
}
