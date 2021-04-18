import Foundation
import DTSharedLibrary

struct DTAction {

    let type: DTActionType
    let strokes: [DTStrokeIndexPair]
    let roomId: UUID
    let doodleId: UUID
    let createdBy: String

    init(action: DTAdaptedAction) {
        self.type = action.type
        self.strokes = action.strokes
        self.roomId = action.roomId
        self.doodleId = action.doodleId
        self.createdBy = action.createdBy
    }

    init(type: DTActionType, roomId: UUID, doodleId: UUID, strokes: [DTStrokeIndexPair], createdBy: String) {
        self.type = type
        self.roomId = roomId
        self.doodleId = doodleId
        self.strokes = strokes
        self.createdBy = createdBy
    }

    init?(type: DTActionType, roomId: UUID, doodleId: UUID, strokes: [(DTStrokeWrapper, Int)], createdBy: String) {
        self.type = type
        self.roomId = roomId
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

    init(partialAction: DTPartialAction, roomId: UUID) {
        type = partialAction.type
        strokes = partialAction.strokes
        doodleId = partialAction.doodleId
        self.roomId = roomId
        self.createdBy = partialAction.createdBy
    }

    func getStrokes() -> [(stroke: DTStrokeWrapper, index: Int)] {
        var wrappers = [(stroke: DTStrokeWrapper, index: Int)]()

        for stroke in strokes {
            guard let wrapper = DTStrokeWrapper(data: stroke.stroke, strokeId: stroke.strokeId,
                                                createdBy: createdBy, isDeleted: stroke.isDeleted) else {
                continue
            }

            wrappers.append((stroke: wrapper, index: stroke.index))
        }

        return wrappers
    }
}

// MARK: - Hashable

extension DTAction: Hashable {

}
