import Vapor
import DTSharedLibrary

extension DTAdaptedText {
    init(text: PersistedDTEntity) {
        self.init(
            text: text.entityData,
            textId: text.entityId,
            roomId: text.roomId,
            doodleId: text.$doodle.id,
            createdBy: text.createdBy,
            isDeleted: text.isDeleted

        )
    }

    func makePersistedText() -> PersistedDTEntity {
        PersistedDTEntity(
            type: .text,
            entityData: text,
            entityId: textId,
            roomId: roomId,
            doodleId: doodleId,
            createdBy: createdBy,
            isDeleted: isDeleted
        )
    }

    func isSameText(as persisted: PersistedDTEntity) -> Bool {
        textId == persisted.entityId &&
            roomId == persisted.roomId &&
            doodleId == persisted.$doodle.id &&
            createdBy == persisted.createdBy
    }
}

// MARK: - Content

extension DTAdaptedText: Content {}
