import Foundation
import DoodlingLibrary

struct DTAction {

    let strokesAdded: Data
    let strokesRemoved: Data

    init(strokesAdded: Data, strokesRemoved: Data) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
    }

    init?<S: DTStroke>(added: Set<S>, removed: Set<S>) {
        let encoder = JSONEncoder()

        guard let addedData = try? encoder.encode(added),
              let removedData = try? encoder.encode(removed) else {
            return nil
        }

        strokesAdded = addedData
        strokesRemoved = removedData
    }

    func getStrokes<S: DTStroke>() -> (added: Set<S>, removed: Set<S>)? {
        let decoder = JSONDecoder()
        guard let added = try? decoder.decode(Set<S>.self, from: strokesAdded),
              let removed = try? decoder.decode(Set<S>.self, from: strokesRemoved) else {
            return nil
        }
        return (added, removed)
    }

}

// MARK: - Hashable

extension DTAction: Hashable {

}
