import Foundation

public struct DTAdaptedDoodle: Codable {

    public let roomId: UUID
    public var strokes: [DTAdaptedStroke]

    public init(roomId: UUID, strokes: [DTAdaptedStroke] = []) {
        self.strokes = strokes
        self.roomId = roomId
    }

}

// MARK: - Hashable

extension DTAdaptedDoodle: Hashable {}
