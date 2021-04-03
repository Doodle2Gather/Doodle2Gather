import Foundation
import DoodlingLibrary
import DoodlingAdaptedLibrary

struct DTAction {

    let strokesAdded: Set<Data>
    let strokesRemoved: Set<Data>

    init(action: DTAdaptedAction) {
        self.strokesAdded = action.strokesAdded
        self.strokesRemoved = action.strokesRemoved
    }

    init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
    }

    init?<S: DTStroke>(added: Set<S>, removed: Set<S>) {
        let encoder = JSONEncoder()

        var addedData = Set<Data>()
        var removedData = Set<Data>()

        for stroke in added {
            guard let addedStroke = try? encoder.encode(stroke) else {
                return nil
            }
            addedData.insert(addedStroke)
        }

        for stroke in removed {
            guard let removedStroke = try? encoder.encode(stroke) else {
                return nil
            }
            removedData.insert(removedStroke)
        }

        strokesAdded = addedData
        strokesRemoved = removedData
    }

    func getStrokes<S: DTStroke>() -> (added: Set<S>, removed: Set<S>)? {
        let decoder = JSONDecoder()

        var added = Set<S>()
        var removed = Set<S>()

        for stroke in strokesAdded {
            guard let addedStroke = try? decoder.decode(S.self, from: stroke) else {
                return nil
            }
            added.insert(addedStroke)
        }

        for stroke in strokesRemoved {
            guard let removedStroke = try? decoder.decode(S.self, from: stroke) else {
                return nil
            }
            removed.insert(removedStroke)
        }

        return (added, removed)
    }
}

// MARK: - Hashable

extension DTAction: Hashable {

}
