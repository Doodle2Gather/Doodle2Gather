import Foundation

public struct DTFetchDoodleMessage: Codable {
    var type = DTRoomMessageType.fetchDoodle
    public let id: UUID
    public let success: Bool
    public let message: String
    public let doodles: [DTAdaptedDoodle]

    public init(id: UUID, success: Bool, message: String, doodles: [DTAdaptedDoodle]) {
        self.id = id
        self.success = success
        self.message = message
        self.doodles = doodles
    }
}
