import Foundation

public struct DTMessage: Codable {
    public let type: DTMessageType
    public let id: UUID
}

public struct DTAuthMessage: Codable {
    public let subtype: DTAuthMessageType
}

public struct DTHomeMessage: Codable {
    public let subtype: DTHomeMessageType
}

public struct DTRoomMessage: Codable {
    public let subtype: DTRoomMessageType
    public let roomId: UUID
}

