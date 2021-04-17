import Foundation

public struct DTRequestFetchMessage: Codable {
    var type = DTMessageType.requestFetch
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
