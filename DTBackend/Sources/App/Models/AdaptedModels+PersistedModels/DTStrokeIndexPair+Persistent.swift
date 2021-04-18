import Vapor
import DTSharedLibrary

extension DTStrokeIndexPair {
    init(_ persisted: PersistedDTStrokeIndexPair) {
        self.init(
            persisted.stroke,
            persisted.index,
            strokeId: persisted.strokeId,
            isDeleted: persisted.isDeleted
        )
    }

    func makePersistedPair() -> PersistedDTStrokeIndexPair {
        PersistedDTStrokeIndexPair(
            stroke: stroke,
            index: index,
            strokeId: strokeId,
            isDeleted: isDeleted
        )
    }

    func isSamePair(as persisted: PersistedDTStrokeIndexPair) -> Bool {
        strokeId == persisted.strokeId &&
            index == persisted.index
    }
}

// MARK: - Content

extension DTStrokeIndexPair: Content {}
