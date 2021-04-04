import Foundation

public struct DTMessage: Codable {
    public let type: DTMessageType
    public let id: UUID
}
