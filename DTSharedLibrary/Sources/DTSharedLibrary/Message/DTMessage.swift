import Foundation

public struct DTMessage: Codable {
    public let type: DTRoomMessageType
    public let id: UUID
}
