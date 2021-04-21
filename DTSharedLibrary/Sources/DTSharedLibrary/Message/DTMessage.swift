import Foundation

/// Represents the messages sent between client and server through WebSocket
public struct DTMessage: Codable {
    public let type: DTMessageType
    public let id: UUID
}

/// Represents the message sent by the server to a client to establish WebSocket connection
public struct DTHandshake: Codable {
    var type = DTMessageType.handshake
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
