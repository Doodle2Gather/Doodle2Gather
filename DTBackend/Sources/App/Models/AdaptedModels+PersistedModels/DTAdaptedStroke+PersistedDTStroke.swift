import Vapor
import DTSharedLibrary

extension DTAdaptedStroke {
    init(stroke: PersistedDTStroke) {
        self.init(
            stroke: stroke.strokeData,
            strokeId: stroke.strokeId,
            roomId: stroke.roomId,
            doodleId: stroke.$doodle.id,
            createdBy: stroke.createdBy,
            isDeleted: stroke.isDeleted

        )
    }

    func makePersistedStroke() -> PersistedDTStroke {
        PersistedDTStroke(
            strokeData: stroke,
            strokeId: strokeId,
            roomId: roomId,
            doodleId: doodleId,
            createdBy: createdBy,
            isDeleted: isDeleted
        )
    }

    func isSameStroke(as persisted: PersistedDTStroke) -> Bool {
        strokeId == persisted.strokeId &&
            roomId == persisted.roomId &&
            doodleId == persisted.$doodle.id &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
