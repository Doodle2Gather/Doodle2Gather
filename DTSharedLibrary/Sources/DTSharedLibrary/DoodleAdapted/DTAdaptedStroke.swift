import Foundation

public struct DTAdaptedStroke: Codable {

    public let stroke: Data
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: UUID

    public init(stroke: Data, roomId: UUID, doodleId: UUID, createdBy: UUID) {
        self.stroke = stroke
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
    }

    public init(_ strokeIndexPair: DTStrokeIndexPair, roomId: UUID, doodleId: UUID, createdBy: UUID) {
        self.init(stroke: strokeIndexPair.stroke, roomId: roomId, doodleId: doodleId, createdBy: createdBy)
    }
}

// MARK: - Hashable

extension DTAdaptedStroke: Hashable {
    public static func == (lhs: DTAdaptedStroke, rhs: DTAdaptedStroke) -> Bool {
        return
            lhs.stroke == rhs.stroke &&
            lhs.roomId == rhs.roomId &&
            lhs.doodleId == rhs.doodleId
    }
}
