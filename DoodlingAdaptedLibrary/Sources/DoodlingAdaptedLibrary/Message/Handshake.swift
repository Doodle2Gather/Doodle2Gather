import Foundation

public struct Handshake: Codable {
    var type = DTMessageType.handshake
    let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}
