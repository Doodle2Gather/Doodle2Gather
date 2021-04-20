import Vapor
import DTSharedLibrary

/// Supports the conversion between `DTAdaptedAction` and `PersistedDTAction`
extension DTAdaptedAction {
    init(action: PersistedDTAction) {
        self.init(
            type: DTActionType(rawValue: action.type) ?? .unknown,
            entities: action.entities.map { DTEntityIndexPair($0) },
            roomId: action.roomId,
            doodleId: action.$doodle.id,
            createdBy: action.createdBy
        )
    }

    func makePersistedAction() -> PersistedDTAction {
        PersistedDTAction(
            type: type,
            entities: entities.map { $0.makePersistedPair() },
            roomId: roomId,
            doodleId: doodleId,
            createdBy: createdBy
        )
    }
}

// MARK: - Content

extension DTAdaptedAction: Content {}
