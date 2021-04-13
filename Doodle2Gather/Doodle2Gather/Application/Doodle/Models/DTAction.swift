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
        print("Decoding")
        print(String(data: strokes[0].stroke, encoding: .utf8))
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
        print("init strokes")
        for (stroke, index) in strokes {
            guard let data = try? encoder.encode(stroke) else {
                return nil
            }
            print(String(data: data, encoding: .utf8))
            strokesData.append(DTStrokeIndexPair(data, index))
        }
        self.strokes = strokesData
    }

    func getStrokes<S: DTStroke>() -> [S]? {
        let decoder = JSONDecoder()

        var strokeArr = [S]()
        print("getting strokes")
        for pair in strokes {
            guard let stroke = try? decoder.decode(S.self, from: pair.stroke) else {
                return nil
            }
            print(String(data: pair.stroke, encoding: .utf8))
            strokeArr.append(stroke)
        }
        return strokeArr
    }
}

// MARK: - Hashable

extension DTAction: Hashable {

}
