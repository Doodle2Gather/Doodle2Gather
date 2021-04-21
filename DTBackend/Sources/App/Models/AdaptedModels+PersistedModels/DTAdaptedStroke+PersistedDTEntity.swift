import Vapor
import DTSharedLibrary

/// Supports the conversion between `DTAdaptedStroke` and `PersistedDTEntity`
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

    func belongsToDoodle(_ doodle: PersistedDTDoodle) -> Bool {
        guard let persistedId = try? doodle.requireID() else {
            return false
        }
        return doodleId == persistedId
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
