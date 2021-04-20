import UIKit

struct VideoCallUser: Hashable {
    let uid: UInt
    let userId: String
    let overlay: UIView
    let nameplate: UILabel

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
}
