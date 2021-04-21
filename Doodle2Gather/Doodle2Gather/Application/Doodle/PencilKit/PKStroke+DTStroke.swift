import PencilKit
import DTSharedLibrary

/// Adapts `PKStroke` to work with implementations used in Doodle2Gather.
extension PKStroke: DTStroke {

    public var points: [PKStrokePoint] {
        get {
            path.compactMap { $0 }
        }
        set {
            path = PKStrokePath(controlPoints: newValue, creationDate: Date())
        }
    }

    public var color: UIColor {
        get {
            ink.color
        }
        set {
            ink.color = newValue
        }
    }

    public var tool: DTCodableTool {
        get {
            convertInkToTool(ink: ink.inkType)
        }
        set {
            ink.inkType = convertToolToInk(tool: newValue)
        }
    }

    public init<S>(from stroke: S) where S: DTStroke {
        self.init(color: stroke.color, tool: stroke.tool, points: stroke.points,
                  transform: stroke.transform, mask: stroke.mask)
    }

    public init?(from stroke: DTAdaptedStroke) {
        let decoder = JSONDecoder()

        guard let stroke = try? decoder.decode(PKStroke.self, from: stroke.stroke) else {
            return nil
        }

        self.init(from: stroke)
    }

    public init<P>(color: UIColor, tool: DTCodableTool, points: [P], transform: CGAffineTransform,
                   mask: UIBezierPath?) where P: DTPoint {
        var ink = PKInk.InkType.pen
        switch tool {
        case .pen:
            ink = .pen
        case .pencil:
            ink = .pencil
        case .highlighter:
            ink = .marker
        }

        let points = points.map { PKStrokePoint(from: $0) }

        self.init(ink: .init(ink, color: color), path: PKStrokePath(controlPoints: points, creationDate: Date()),
                  transform: transform, mask: mask)
    }

    private func convertToolToInk(tool: DTCodableTool) -> PKInk.InkType {
        switch tool {
        case .pen:
            return .pen
        case .pencil:
            return .pencil
        case .highlighter:
            return .marker
        }
    }

    private func convertInkToTool(ink: PKInk.InkType) -> DTCodableTool {
        switch ink {
        case .pen:
            return .pen
        case .pencil:
            return .pencil
        case .marker:
            return .highlighter
        @unknown default:
            fatalError("Unrecognised ink being used!")
        }
    }

    public mutating func setIsSelected(_ isSelected: Bool) {
        color = isSelected ? color.lighten() : color.darken()
    }

}

// MARK: - Points Frame

/// Adapted from:
/// https://github.com/simonbs/InfiniteCanvas/blob/main/InfiniteCanvas/Source/Canvas/PKDrawing%2BHelpers.swift
extension PKStroke {

    public var pointsFrame: CGRect? {
        guard !points.isEmpty else {
            return nil
        }
        var minPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var maxPoint = CGPoint(x: 0, y: 0)
        for point in points {
            let location = point.location
            minPoint.x = min(location.x, minPoint.x)
            minPoint.y = min(location.y, minPoint.y)
            maxPoint.x = max(location.x, maxPoint.x)
            maxPoint.y = max(location.y, maxPoint.y)
        }

        return CGRect(x: minPoint.x + transform.tx, y: minPoint.y + transform.ty, width: maxPoint.x - minPoint.x,
                      height: maxPoint.y - minPoint.y)
    }

}
