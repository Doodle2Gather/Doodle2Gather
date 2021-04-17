import Foundation

public struct DTAuthMessage: Codable {
    public let id: UUID
    public let subtype: DTAuthMessageType
}
