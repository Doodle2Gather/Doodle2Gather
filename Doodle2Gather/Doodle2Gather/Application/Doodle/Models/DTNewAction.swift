import Foundation
import DTFrontendLibrary
import DTSharedLibrary

struct DTNewAction {

    let type: DTActionType
    let strokes: [Data]
    let strokeIndex: Int

    init(type: DTActionType, strokes: [Data], strokeIndex: Int) {
        self.type = type
        self.strokes = strokes
        self.strokeIndex = strokeIndex
    }

    init?<S: DTStroke>(type: DTActionType, strokes: [S], strokeIndex: Int) {
        self.type = type
        self.strokeIndex = strokeIndex

        let encoder = JSONEncoder()
        var strokesData = [Data]()
        for stroke in strokes {
            guard let data = try? encoder.encode(stroke) else {
                return nil
            }
            strokesData.append(data)
        }
        self.strokes = strokesData
    }

    func getStrokes<S: DTStroke>() -> [S]? {
        let decoder = JSONDecoder()

        var strokeArr = [S]()
        for data in strokes {
            guard let stroke = try? decoder.decode(S.self, from: data) else {
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

enum DTActionType {
    case add, remove, modify
}
