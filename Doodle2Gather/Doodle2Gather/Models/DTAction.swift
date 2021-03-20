import Foundation

struct DTAction {
    /// Encoded strings containing the strokes added or removed.
    let strokesAdded: String
    let strokesRemoved: String

    init?<S: DTStroke>(added: Set<S>, removed: Set<S>) {
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
}

// MARK: - Hashable

extension DTAction: Hashable {

}
