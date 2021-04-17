import Foundation

public struct DTDisconnect: Codable {
    var type = DTRoomMessageType.exitRoom
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
