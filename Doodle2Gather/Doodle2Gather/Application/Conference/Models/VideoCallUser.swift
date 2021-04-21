/// A class to store the pair of uid and userId information required by the AgoraRtcEngine.
class VideoCallUser {
    var uid: UInt
    var userId: String

    init(uid: UInt, userId: String) {
        self.uid = uid
        self.userId = userId
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
