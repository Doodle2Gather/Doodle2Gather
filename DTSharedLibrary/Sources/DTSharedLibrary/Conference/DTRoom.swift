import Foundation

public protocol DTRoom {
    var roomId: UUID { get }
    var roomName: String { get }
    var inviteCode: String { get }
}
