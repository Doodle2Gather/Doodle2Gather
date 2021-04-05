import Foundation
import DTFrontendLibrary
import DTSharedLibrary

// TODO: - some temp fixes are added to make it compile without warnings
// This struct should no longer be in use. All occurence shld be refactored to DTNewAction instead.

struct DTAction {

    let strokes: [Data]

    init(action: DTAdaptedAction) {
        self.strokes = action.strokes.map { $0.stroke }
    }

    init(strokes: [Data]) {
        self.strokes = strokes
    }

    init?<S: DTStroke>(strokes: [S]) {
        let encoder = JSONEncoder()

        var data = [Data]()

        for stroke in strokes {
            guard let addedStroke = try? encoder.encode(stroke) else {
                return nil
            }
            data.append(addedStroke)
        }

        self.strokes = data
    }

    func getStrokes<S: DTStroke>() -> [S]? {
        let decoder = JSONDecoder()

        var added = [S]()

        for stroke in strokes {
            guard let addedStroke = try? decoder.decode(S.self, from: stroke) else {
                return nil
            }
            added.append(addedStroke)
        }

        return added
    }
}

// MARK: - Hashable

extension DTAction: Hashable {

}
