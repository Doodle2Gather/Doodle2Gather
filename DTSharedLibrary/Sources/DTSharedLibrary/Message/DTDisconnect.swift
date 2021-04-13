import Foundation

public struct DTDisconnect: Codable {
    var type = DTMessageType.disconnect
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
