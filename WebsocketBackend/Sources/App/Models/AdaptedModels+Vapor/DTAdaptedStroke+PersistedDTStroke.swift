import Vapor
import DoodlingAdaptedLibrary

extension DTAdaptedStroke {
    init(action: PersistedDTStroke) {
        self.init(
            stroke: action.strokeData,
            roomId: action.roomId,
            createdBy: action.createdBy
        )
    }

    func makePersistedStroke() -> PersistedDTStroke {
        PersistedDTStroke(
            strokeData: stroke,
            roomId: roomId,
            createdBy: createdBy
        )
    }

    func isSameStroke(as persisted: PersistedDTStroke) -> Bool {
        stroke == persisted.strokeData &&
            roomId == persisted.roomId &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
