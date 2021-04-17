import Vapor
import DTSharedLibrary

extension DTStrokeIndexPair {
    init(_ persisted: PersistedDTStrokeIndexPair) {
        self.init(
            persisted.stroke,
            persisted.index
        )
    }

    func makePersistedPair() -> PersistedDTStrokeIndexPair {
        PersistedDTStrokeIndexPair(
            stroke: stroke,
            index: index
        )
    }

    func isSamePair(as persisted: PersistedDTStrokeIndexPair) -> Bool {
        stroke == persisted.stroke &&
            index == persisted.index
    }
}

// MARK: - Content

extension DTStrokeIndexPair: Content {}
