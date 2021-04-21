import UIKit

class VideoCallUser {
    var uid: UInt
    var userId: String
    var overlay: UIView

    init(uid: UInt, userId: String, overlay: UIView) {
        self.uid = uid
        self.userId = userId
        self.overlay = overlay
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
