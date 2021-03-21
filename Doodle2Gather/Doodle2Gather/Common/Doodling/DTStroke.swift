import UIKit

/// Represents a single stroke, consisting of multiple points.
protocol DTStroke: Hashable, Codable {
    associatedtype Point: DTPoint

    var color: UIColor { get set }
    var tool: DTTool { get set }
    var points: [Point] { get set }

    /// Instantiates self using a generalised `DTStroke`.
    init<S: DTStroke>(from stroke: S)

    init<P: DTPoint>(color: UIColor, tool: DTTool, points: [P])

}

// MARK: - Equatable

extension DTStroke {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.color == rhs.color && lhs.tool == rhs.tool && lhs.points == rhs.points
    }

}

// MARK: - Hashable

extension DTStroke {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(tool)
        hasher.combine(points)
    }

}

// MARK: - Codable

extension DTStroke {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DTStrokeCodingKeys.self)
        try container.encode(CodableColor(uiColor: color), forKey: .color)
        try container.encode(tool.rawValue, forKey: .tool)
        try container.encode(points, forKey: .points)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DTStrokeCodingKeys.self)
        let color = try container.decode(CodableColor.self, forKey: .color).uiColor
        let tool = DTTool(rawValue: try container.decode(String.self, forKey: .tool)) ?? .pen
        let points = try container.decode(Array<Point>.self, forKey: .points)

        self.init(color: color, tool: tool, points: points)
    }

}

/// Keys for encoding and decoding `DTStroke`.
enum DTStrokeCodingKeys: CodingKey {
    case color
    case tool
    case points
}
