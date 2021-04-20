import Foundation

/// A datatype that contains the unique identifier for a doodle entity
/// and its index in the array
/// Constructed to aid `DTAdaptedAction` to ensure the cleint and
/// the server's copy of a doodle is in sync
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
