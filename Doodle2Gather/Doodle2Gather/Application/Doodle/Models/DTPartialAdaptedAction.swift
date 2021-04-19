import Foundation
import DTSharedLibrary

struct DTPartialAdaptedAction {

    let type: DTActionType
    let strokes: [DTStrokeIndexPair]
    let doodleId: UUID
    let createdBy: String

    init(type: DTActionType, doodleId: UUID, strokes: [DTStrokeIndexPair], createdBy: String) {
        self.type = type
        self.doodleId = doodleId
        self.strokes = strokes
        self.createdBy = createdBy
    }

    init?(type: DTActionType, doodleId: UUID, strokes: [(DTStrokeWrapper, Int)], createdBy: String) {
        self.type = type
        self.doodleId = doodleId
        self.createdBy = createdBy

        let encoder = JSONEncoder()
        var strokesData = [DTStrokeIndexPair]()

        for (stroke, index) in strokes {
            guard let data = try? encoder.encode(stroke.stroke) else {
                return nil
            }
            strokesData.append(DTStrokeIndexPair(data, index, strokeId: stroke.strokeId, isDeleted: stroke.isDeleted))
        }

        self.strokes = strokesData
    }

}

// MARK: - DTActionProtocol

extension DTPartialAdaptedAction: DTActionProtocol {

    func inverse() -> DTPartialAdaptedAction {
        var newType: DTActionType = .add
        var newStrokes = strokes

        switch type {
        case .add, .unremove:
            newType = .remove
            newStrokes = [DTStrokeIndexPair(strokes[0].stroke, strokes[0].index,
                                            strokeId: strokes[0].strokeId, isDeleted: true)]
        case .modify:
            newType = .modify
            newStrokes = [strokes[1], strokes[0]]
        case .remove:
            newType = .unremove
            newStrokes = [DTStrokeIndexPair(strokes[0].stroke, strokes[0].index,
                                            strokeId: strokes[0].strokeId, isDeleted: false)]
        case .unknown:
            newType = .unknown
        }

        return DTPartialAdaptedAction(type: newType, doodleId: doodleId, strokes: newStrokes,
                                      createdBy: createdBy)
    }

}
