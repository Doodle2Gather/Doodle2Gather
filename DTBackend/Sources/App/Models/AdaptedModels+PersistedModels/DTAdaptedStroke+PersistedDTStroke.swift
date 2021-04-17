import Vapor
import DTSharedLibrary

extension DTAdaptedStroke {
    init(stroke: PersistedDTStroke) {
        self.init(
            stroke: stroke.strokeData,
            roomId: stroke.roomId,
            doodleId: stroke.$doodle.id,
            createdBy: stroke.createdBy
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
            roomId == persisted.roomId &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
