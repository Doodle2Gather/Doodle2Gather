import UIKit

/// Represents a single stroke, consisting of multiple points.
public protocol DTStroke: Hashable, Codable {
    associatedtype Point: DTPoint

    var color: UIColor { get set }
    var tool: DTTool { get set }
    var points: [Point] { get set }
    var mask: UIBezierPath? { get set }
    var transform: CGAffineTransform { get set }

    /// Instantiates self using a generalised `DTStroke`.
    init<S: DTStroke>(from stroke: S)

    init<P: DTPoint>(color: UIColor, tool: DTTool, points: [P], transform: CGAffineTransform,
                     mask: UIBezierPath?)
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
        hasher.combine(mask)
        hasher.combine(transform.a)
        hasher.combine(transform.b)
        hasher.combine(transform.c)
        hasher.combine(transform.d)
        hasher.combine(transform.tx)
        hasher.combine(transform.ty)
    }

}

// MARK: - Codable

extension DTStroke {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DTStrokeCodingKeys.self)
        try container.encode(DTCodableColor(uiColor: color), forKey: .color)
        try container.encode(tool.rawValue, forKey: .tool)
        try container.encode(points, forKey: .points)
        try container.encode(transform, forKey: .transform)
        if let mask = mask {
            let maskData = try NSKeyedArchiver.archivedData(withRootObject: mask, requiringSecureCoding: false)
            try container.encode(maskData, forKey: .mask)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DTStrokeCodingKeys.self)
        let color = try container.decode(DTCodableColor.self, forKey: .color).uiColor
        let tool = DTTool(rawValue: try container.decode(String.self, forKey: .tool)) ?? .pen
        let points = try container.decode(Array<Point>.self, forKey: .points)
        let transform = try container.decode(CGAffineTransform.self, forKey: .transform)

        var mask: UIBezierPath?
        if container.contains(.mask) {
            let maskData = try container.decode(Data.self, forKey: .mask)
            mask = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(maskData) as? UIBezierPath
        }

        self.init(color: color, tool: tool, points: points, transform: transform, mask: mask)
    }

}

/// Keys for encoding and decoding `DTStroke`.
enum DTStrokeCodingKeys: CodingKey {
    case color
    case tool
    case points
    case transform
    case mask
}
