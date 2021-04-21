import Foundation
import DTSharedLibrary

// MARK: - DTActionProtocol

extension DTAdaptedAction: DTActionProtocol {

    init(action: DTActionProtocol, roomId: UUID) {
        self.init(type: action.type, entities: action.entities, roomId: roomId,
                  doodleId: action.doodleId, createdBy: action.createdBy)
    }

    func invert() -> DTAdaptedAction {
        var newType: DTActionType = .add
        var newStrokes = entities

        switch type {
        case .add, .unremove:
            newType = .remove
            newStrokes = [
                DTEntityIndexPair(entities[0].entity, entities[0].index,
                                  type: .stroke, entityId: entities[0].entityId, isDeleted: true)
            ]
        case .modify:
            newType = .modify
            newStrokes = [entities[1], entities[0]]
        case .remove:
            newType = .unremove
            newStrokes = [
                DTEntityIndexPair(entities[0].entity, entities[0].index,
                                  type: .stroke, entityId: entities[0].entityId, isDeleted: false)
            ]
        }

        return DTAdaptedAction(type: newType, entities: newStrokes,
                               roomId: roomId, doodleId: doodleId,
                               createdBy: createdBy)
    }

}
