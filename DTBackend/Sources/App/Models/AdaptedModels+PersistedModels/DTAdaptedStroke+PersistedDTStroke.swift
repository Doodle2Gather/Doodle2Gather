import Vapor
import DTSharedLibrary

extension DTAdaptedStroke {
    init(action: PersistedDTStroke) {
        self.init(
            stroke: action.strokeData,
            roomId: action.$room.id,
            doodleId: action.$doodle.id,
            createdBy: action.createdBy
        )
    }

    func makePersistedStroke() -> PersistedDTStroke {
        PersistedDTStroke(
            strokeData: stroke,
            roomId: roomId,
            doodleId: doodleId,
            createdBy: createdBy
        )
    }

    func isSameStroke(as persisted: PersistedDTStroke) -> Bool {
        stroke == persisted.strokeData &&
            roomId == persisted.$room.id &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
