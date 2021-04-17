import Foundation

public struct DTHandshake: Codable {
    var type = DTRoomMessageType.handshake
    public let id: UUID
    public let users: [DTAdaptedUser]

    public init(id: UUID, users: [DTAdaptedUser]) {
        self.id = id
        self.users = users
    }
}
