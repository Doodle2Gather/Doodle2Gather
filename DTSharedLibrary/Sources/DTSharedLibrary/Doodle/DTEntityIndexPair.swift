import Foundation

public struct DTEntityIndexPair: Codable, Hashable {
    public let type: DTEntityType
    public let entityId: UUID
    public let entity: Data
    public let index: Int
    public let isDeleted: Bool

    public init(_ entity: Data, _ index: Int, type: DTEntityType, entityId: UUID, isDeleted: Bool) {
        self.type = type
        self.entityId = entityId
        self.entity = entity
        self.index = index
        self.isDeleted = isDeleted
    }
}
