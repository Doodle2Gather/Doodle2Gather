import Foundation

public protocol DTEntityIndexPair: Codable, Hashable {
    var entityId: UUID { get }
    var entity: Data { get }
    var index: Int { get }
    var isDeleted: Bool { get }
}

public struct DTStrokeIndexPair: DTEntityIndexPair {
    public var entityId: UUID
    public var entity: Data
    public var index: Int
    public var isDeleted: Bool

    public var strokeId: UUID { entityId }
    public var stroke: Data { entity }

    public init(_ stroke: Data, _ index: Int, strokeId: UUID, isDeleted: Bool) {
        self.entityId = strokeId
        self.entity = stroke
        self.index = index
        self.isDeleted = isDeleted
    }
}

public struct DTTextIndexPair: DTEntityIndexPair {
    public var entityId: UUID
    public var entity: Data
    public var index: Int
    public var isDeleted: Bool

    public var textId: UUID { entityId }
    public var text: Data { entity }

    public init(_ text: Data, _ index: Int, textId: UUID, isDeleted: Bool) {
        self.entityId = textId
        self.entity = text
        self.index = index
        self.isDeleted = isDeleted
    }
}
