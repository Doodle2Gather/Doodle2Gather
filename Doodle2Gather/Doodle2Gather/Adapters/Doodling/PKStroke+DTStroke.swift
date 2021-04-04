import PencilKit
import DoodlingLibrary

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

    public var tool: DTTool {
        get {
            convertInkToTool(ink: ink.inkType)
        }
        set {
            ink.inkType = convertToolToInk(tool: newValue)
        }
    }

    public init<S>(from stroke: S) where S: DTStroke {
        self.init(color: stroke.color, tool: stroke.tool, points: stroke.points)
    }

    public init<P>(color: UIColor, tool: DTTool, points: [P]) where P: DTPoint {
        var ink = PKInk.InkType.pen
        switch tool {
        case .pen, .eraser:
            ink = .pen
        case .pencil:
            ink = .pencil
        case .marker:
            ink = .marker
        }

        let points = points.map { PKStrokePoint(from: $0) }

        self.init(ink: .init(ink, color: color), path: PKStrokePath(controlPoints: points, creationDate: Date()))
    }

    private func convertToolToInk(tool: DTTool) -> PKInk.InkType {
        switch tool {
        case .pen, .eraser:
            return .pen
        case .pencil:
            return .pencil
        case .marker:
            return .marker
        }
    }

    private func convertInkToTool(ink: PKInk.InkType) -> DTTool {
        switch ink {
        case .pen:
            return .pen
        case .pencil:
            return .pencil
        case .marker:
            return .marker
        @unknown default:
            fatalError("Unrecognised ink being used!")
        }
    }
}