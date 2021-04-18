import Foundation

public struct DTAdaptedStroke: Codable {

    public let stroke: Data
    public let strokeId: UUID
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: String
    public var isDeleted: Bool

    public init(stroke: Data, strokeId: UUID,
                roomId: UUID, doodleId: UUID,
                createdBy: String, isDeleted: Bool = false) {
        self.stroke = stroke
        self.strokeId = strokeId
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
        self.isDeleted = isDeleted
    }

    public init(_ strokeIndexPair: DTStrokeIndexPair, roomId: UUID, doodleId: UUID, createdBy: String) {
        self.init(stroke: strokeIndexPair.stroke, strokeId: strokeIndexPair.strokeId,
                  roomId: roomId, doodleId: doodleId,
                  createdBy: createdBy, isDeleted: strokeIndexPair.isDeleted)
    }

    public mutating func safeDelete() {
        isDeleted = true
    }

    public mutating func safeUndelete() {
        isDeleted = false
    }
}

// MARK: - Hashable

extension DTAdaptedStroke: Hashable {
    public static func == (lhs: DTAdaptedStroke, rhs: DTAdaptedStroke) -> Bool {
        lhs.stroke == rhs.stroke &&
            lhs.roomId == rhs.roomId &&
            lhs.doodleId == rhs.doodleId
    }
}
