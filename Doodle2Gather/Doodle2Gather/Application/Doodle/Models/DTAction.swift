import Foundation
import DTSharedLibrary

struct DTAction {

    let type: DTActionType
    let strokes: [DTStrokeIndexPair]
    let roomId: UUID
    let doodleId: UUID

    init(action: DTAdaptedAction) {
        self.type = action.type
        self.strokes = action.strokes
        self.roomId = action.roomId
        self.doodleId = action.doodleId
    }

    init(type: DTActionType, roomId: UUID, doodleId: UUID, strokes: [DTStrokeIndexPair]) {
        self.type = type
        self.roomId = roomId
        self.doodleId = doodleId
        self.strokes = strokes
    }

    init?<S: DTStroke>(type: DTActionType, roomId: UUID, doodleId: UUID, strokes: [(S, Int)]) {
        self.type = type
        self.roomId = roomId
        self.doodleId = doodleId

        let encoder = JSONEncoder()
        var strokesData = [DTStrokeIndexPair]()

        for (stroke, index) in strokes {
            guard let data = try? encoder.encode(stroke) else {
                return nil
            }
//            strokesData.append(DTStrokeIndexPair(data, index))
        }
        self.strokes = strokesData
    }

    func getStrokes<S: DTStroke>() -> [S]? {
        let decoder = JSONDecoder()

        var strokeArr = [S]()

        for pair in strokes {
            guard let stroke = try? decoder.decode(S.self, from: pair.stroke) else {
                return nil
            }

            strokeArr.append(stroke)
        }
        return strokeArr
    }
}

// MARK: - Hashable

extension DTAction: Hashable {

}
