import Vapor
import DTSharedLibrary

extension DTAdaptedStroke {
    init(stroke: PersistedDTEntity) {
        self.init(
            stroke: stroke.entityData,
            strokeId: stroke.entityId,
            roomId: stroke.roomId,
            doodleId: stroke.$doodle.id,
            createdBy: stroke.createdBy,
            isDeleted: stroke.isDeleted

        )
    }

    func makePersistedStroke() -> PersistedDTEntity {
        PersistedDTEntity(
            type: .stroke,
            entityData: stroke,
            entityId: strokeId,
            roomId: roomId,
            doodleId: doodleId,
            createdBy: createdBy,
            isDeleted: isDeleted
        )
    }

    func isSameStroke(as persisted: PersistedDTEntity) -> Bool {
        strokeId == persisted.entityId &&
            roomId == persisted.roomId &&
            doodleId == persisted.$doodle.id &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
