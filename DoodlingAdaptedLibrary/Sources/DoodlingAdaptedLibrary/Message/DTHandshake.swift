import Foundation

public struct DTHandshake: Codable {
    var type = DTMessageType.handshake
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}
