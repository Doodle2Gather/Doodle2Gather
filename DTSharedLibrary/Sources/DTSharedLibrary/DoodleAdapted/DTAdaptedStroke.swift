import Foundation

public struct DTAdaptedStroke: Codable {

    public let stroke: Data
    public let roomId: UUID
    public let createdBy: UUID

    public init(stroke: Data, roomId: UUID, createdBy: UUID) {
        self.stroke = stroke
        self.roomId = roomId
        self.createdBy = createdBy
    }
}

// MARK: - Hashable

extension DTAdaptedStroke: Hashable {}
