import Vapor
import DTSharedLibrary

extension DTAdaptedAction {
    init(action: PersistedDTAction) {
        self.init(
            type: DTActionType(rawValue: action.type) ?? .unknown,
            strokes: action.strokes,
            roomId: action.roomId,
            createdBy: action.createdBy
        )
    }

    func makePersistedAction() -> PersistedDTAction {
        PersistedDTAction(
            type: type,
            strokes: strokes,
            roomId: roomId,
            createdBy: createdBy
        )
    }
}

// MARK: - Content

extension DTAdaptedAction: Content {}
