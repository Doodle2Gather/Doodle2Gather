import Foundation

public struct DTAdaptedDoodle: Codable {

    public let roomId: UUID
    public let doodleId: UUID?
    public var strokes: [DTAdaptedStroke]

    public init(roomId: UUID, doodleId: UUID? = nil, strokes: [DTAdaptedStroke] = []) {
        self.strokes = strokes
        self.roomId = roomId
        self.doodleId = doodleId
    }

    public var strokeCount: Int {
        strokes.count
    }

    public func getStroke(at index: Int) -> DTAdaptedStroke {
        strokes[index]
    }

    public mutating func addStroke(_ stroke: DTAdaptedStroke) {
        strokes.append(stroke)
    }

    public mutating func removeStroke(at index: Int) {
        strokes.remove(at: index)
    }

    public mutating func modifyStroke(at index: Int, to newStroke: DTAdaptedStroke) {
        strokes[index] = newStroke
    }

}

// MARK: - Hashable

extension DTAdaptedDoodle: Hashable {}