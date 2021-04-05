import Foundation

public struct DTFetchDoodleMessage: Codable {
    var type = DTMessageType.fetchDoodle
    public let success: Bool
    public let message: String
    public let doodles: [DTAdaptedDoodle]

    public init(success: Bool, message: String, doodles: [DTAdaptedDoodle]) {
        self.success = success
        self.message = message
        self.doodles = doodles
    }
}
