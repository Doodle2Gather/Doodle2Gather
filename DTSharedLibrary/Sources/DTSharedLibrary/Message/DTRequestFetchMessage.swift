import Foundation

public struct DTRequestFetchMessage: Codable {
    var type = DTRoomMessageType.requestFetch
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
