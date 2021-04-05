import Foundation

public struct DTAdaptedDoodle: Codable {
    public typealias Stroke = DTAdaptedStroke
    
    public let roomId: UUID
    public var strokes: [Stroke]

    public init(roomId: UUID, strokes: [Stroke]) {
        self.strokes = strokes
        self.roomId = roomId
    }
}

// MARK: - Hashable

extension DTAdaptedDoodle: Hashable {}
