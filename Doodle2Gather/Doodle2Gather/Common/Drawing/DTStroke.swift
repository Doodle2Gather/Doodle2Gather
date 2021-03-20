import UIKit
import PencilKit // TODO: Remove once placeholder below is removed.

protocol DTStroke: Hashable, Codable {
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

// MARK: - Codable

extension DTStroke {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DTStrokeCodingKeys.self)
        try container.encode(CodableColor(uiColor: color), forKey: .color)
    }

    public init(from decoder: Decoder) throws {
        // TODO: Remove this placeholder init once more properties have been added.
        self.init(from: PKStroke(ink: .init(.marker, color: .black), path: .init()))
        let container = try decoder.container(keyedBy: DTStrokeCodingKeys.self)
        color = try container.decode(CodableColor.self, forKey: .color).uiColor
    }

}

/// Keys for encoding and decoding `DTStroke`.
enum DTStrokeCodingKeys: CodingKey {
    case color
}
