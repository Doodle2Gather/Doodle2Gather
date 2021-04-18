import Foundation

public struct DTStrokeIndexPair: Codable {
    public let strokeId: UUID
    public let stroke: Data
    public let index: Int
    public let isDeleted: Bool

    public init(_ stroke: Data, _ index: Int, strokeId: UUID, isDeleted: Bool) {
        self.stroke = stroke
        self.index = index
        self.strokeId = strokeId
        self.isDeleted = isDeleted
    }
}

extension DTStrokeIndexPair: Hashable {}
