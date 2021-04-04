import Foundation
import DoodlingLibrary

struct DTAction {

    /// Encoded strings containing the strokes added or removed.
    let strokesAdded: String
    let strokesRemoved: String

    init(strokesAdded: String, strokesRemoved: String) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
    }

    init?<S: DTStroke>(added: [S], removed: [S]) {
        let encoder = JSONEncoder()

        guard let addedData = try? encoder.encode(added),
              let removedData = try? encoder.encode(removed),
              let addedString = String(data: addedData, encoding: .utf8),
              let removedString = String(data: removedData, encoding: .utf8) else {
            return nil
        }

        strokesAdded = addedString
        strokesRemoved = removedString
    }

    func getStrokes<S: DTStroke>() -> (added: [S], removed: [S])? {
        let decoder = JSONDecoder()
        guard let addedData = strokesAdded.data(using: .utf8),
              let removedData = strokesRemoved.data(using: .utf8),
              let added = try? decoder.decode([S].self, from: addedData),
              let removed = try? decoder.decode([S].self, from: removedData) else {
            return nil
        }
        return (added, removed)
    }

}

// MARK: - Hashable

extension DTAction: Hashable {
}
