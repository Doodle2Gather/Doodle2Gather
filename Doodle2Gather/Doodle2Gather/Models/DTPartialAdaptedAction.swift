import Foundation
import DTSharedLibrary

struct DTPartialAdaptedAction {

    let type: DTActionType
    let entities: [DTEntityIndexPair]
    let doodleId: UUID
    let createdBy: String

    /// Initializes a partial action using `DTEntityIndexPair`s directly.
    init(type: DTActionType, doodleId: UUID, strokes: [DTEntityIndexPair], createdBy: String) {
        self.type = type
        self.doodleId = doodleId
        self.entities = strokes
        self.createdBy = createdBy
    }

    /// Initializes a partial action using tuples of `DTStrokeWrapper` and their indices.
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

    func invert() -> DTPartialAdaptedAction {
        var newType: DTActionType = .add
        var newStrokes = entities

        switch type {
        case .add:
            newType = .remove
            newStrokes = [
                DTEntityIndexPair(entities[0].entity, entities[0].index,
                                  type: .stroke, entityId: entities[0].entityId, isDeleted: true)
            ]
        case .unremove:
            newType = .remove
            newStrokes = entities.map { DTEntityIndexPair($0.entity, $0.index, type: .stroke,
                                                          entityId: $0.entityId, isDeleted: true)
            }
        case .modify:
            newType = .modify
            newStrokes = [entities[1], entities[0]]
        case .remove:
            newType = .unremove
            newStrokes = entities.map { DTEntityIndexPair($0.entity, $0.index, type: .stroke,
                                                          entityId: $0.entityId, isDeleted: false)
            }
        }

        return DTPartialAdaptedAction(type: newType, doodleId: doodleId, strokes: newStrokes,
                                      createdBy: createdBy)
    }

}
