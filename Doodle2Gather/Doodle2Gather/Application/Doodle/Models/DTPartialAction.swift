import Foundation
import DTSharedLibrary

struct DTPartialAction {

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
