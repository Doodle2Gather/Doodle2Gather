import Foundation
import DTSharedLibrary

struct DTPartialAdaptedAction {

    let type: DTActionType
    let entities: [DTEntityIndexPair]
    let doodleId: UUID
    let createdBy: String

    init(type: DTActionType, doodleId: UUID, strokes: [DTEntityIndexPair], createdBy: String) {
        self.type = type
        self.doodleId = doodleId
        self.entities = strokes
        self.createdBy = createdBy
    }

    init?(type: DTActionType, doodleId: UUID, strokes: [(DTStrokeWrapper, Int)], createdBy: String) {
        self.type = type
        self.doodleId = doodleId
        self.createdBy = createdBy

        let encoder = JSONEncoder()
        var strokesData = [DTEntityIndexPair]()

        for (stroke, index) in strokes {
            guard let data = try? encoder.encode(stroke.stroke) else {
                return nil
            }
            strokesData.append(
                DTEntityIndexPair(data, index, type: .stroke, entityId: stroke.strokeId, isDeleted: stroke.isDeleted)
            )
        }

        self.entities = strokesData
    }

}

// MARK: - DTActionProtocol

extension DTPartialAdaptedAction: DTActionProtocol {

    func inverse() -> DTPartialAdaptedAction {
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

        return DTPartialAdaptedAction(type: newType, doodleId: doodleId, strokes: newStrokes,
                                      createdBy: createdBy)
    }

}
