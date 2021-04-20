import Foundation
import DTSharedLibrary

// MARK: - DTActionProtocol

extension DTAdaptedAction: DTActionProtocol {

    init(partialAction: DTPartialAdaptedAction, roomId: UUID) {
        self.init(type: partialAction.type, entities: partialAction.entities, roomId: roomId,
                  doodleId: partialAction.doodleId, createdBy: partialAction.createdBy)
    }

    func inverse() -> DTAdaptedAction {
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
        case .unknown:
            newType = .unknown
        }

        return DTAdaptedAction(type: newType, entities: newStrokes,
                               roomId: roomId, doodleId: doodleId,
                               createdBy: createdBy)
    }

}
