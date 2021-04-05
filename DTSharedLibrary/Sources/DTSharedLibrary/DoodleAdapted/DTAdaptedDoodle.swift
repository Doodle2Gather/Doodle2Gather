import Foundation

public struct DTAdaptedDoodle: Codable {

    public let roomId: UUID
    public var strokes: [DTAdaptedStroke]

    public init(roomId: UUID, strokes: [DTAdaptedStroke] = []) {
        self.strokes = strokes
        self.roomId = roomId
    }

    public var strokeCount: Int {
        strokes.count
    }

    public func getStroke(at index: Int) -> DTAdaptedStroke {
        strokes[index]
    }

}

// MARK: - Hashable

extension DTAdaptedDoodle: Hashable {}
