import Vapor
import DTSharedLibrary

extension DTAdaptedAction {
    init(action: PersistedDTAction) {
        self.init(
            strokesAdded: action.strokesAdded,
            strokesRemoved: action.strokesRemoved,
            roomId: action.roomId,
            createdBy: action.createdBy
        )
    }

    func makePersistedAction() -> PersistedDTAction {
        PersistedDTAction(
            strokesAdded: strokesAdded,
            strokesRemoved: strokesRemoved,
            roomId: roomId,
            createdBy: createdBy
        )
    }
}

// MARK: - Content

extension DTAdaptedAction: Content {}
