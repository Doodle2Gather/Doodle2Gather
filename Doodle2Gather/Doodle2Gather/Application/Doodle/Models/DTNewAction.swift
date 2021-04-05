import Foundation
import DTFrontendLibrary
import DTSharedLibrary

struct DTNewAction {

    let type: DTActionType
    let strokes: [DTStrokeIndexPair]
    let roomId: UUID
    let doodleId: UUID

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
            strokesData.append(DTStrokeIndexPair(data, index))
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

extension DTNewAction: Hashable {

}
