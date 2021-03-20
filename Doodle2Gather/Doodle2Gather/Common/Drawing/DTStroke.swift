import UIKit

protocol DTStroke: Hashable {
    var color: UIColor { get set }

    /// Instantiates self using a generalised `DTStroke`.
    init<S: DTStroke>(from stroke: S)
}

// MARK: - Equatable

extension DTStroke {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.color == rhs.color
    }

}

// MARK: - Hashable

extension DTStroke {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
    }

}
