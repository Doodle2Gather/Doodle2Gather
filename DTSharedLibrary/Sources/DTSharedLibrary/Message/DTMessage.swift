import Foundation

public struct DTMessage: Codable {
    public let type: DTMessageType
    public let id: UUID
}

public struct DTHandshake: Codable {
    var type = DTMessageType.handshake
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
