import Vapor
import DTSharedLibrary

/// Supports the conversion between `DTEntityIndexPair` and `PersistedDTEntityIndexPair`
extension DTEntityIndexPair {
    init(_ persisted: PersistedDTEntityIndexPair) {
        self.init(
            persisted.entity,
            persisted.index,
            type: persisted.type,
            entityId: persisted.entityId,
            isDeleted: persisted.isDeleted
        )
    }

    func makePersistedPair() -> PersistedDTEntityIndexPair {
        PersistedDTEntityIndexPair(
            type: type, entity: entity,
            index: index,
            entityId: entityId,
            isDeleted: isDeleted
        )
    }

    func isSamePair(as persisted: PersistedDTEntityIndexPair) -> Bool {
        entityId == persisted.entityId &&
            index == persisted.index
    }
}

// MARK: - Content

extension DTEntityIndexPair: Content {}
