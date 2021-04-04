import DoodlingLibrary
import PencilKit
import CoreGraphics

struct PKDrawingHashWrapper: DTDoodle {

    var dtStrokes: [PKStrokeHashWrapper]

    init<D>(from doodle: D) where D: DTDoodle {
        self.dtStrokes = doodle.dtStrokes.map { PKStrokeHashWrapper(from: $0) }
    }

    mutating func removeStrokes<S>(_: [S]) where S: DTStroke {
        // No op.
    }

    mutating func addStrokes<S>(_: [S]) where S: DTStroke {
        // No op.
    }

}

struct PKStrokeHashWrapper: DTStroke {

    var color: UIColor
    var tool: DTTool
    var points: [PKStrokePointHashWrapper]

    init<S>(from stroke: S) where S: DTStroke {
        self.color = stroke.color
        self.tool = stroke.tool
        self.points = stroke.points.map { PKStrokePointHashWrapper(from: $0) }
    }

    init<P>(color: UIColor, tool: DTTool, points: [P]) where P: DTPoint {
        self.color = color
        self.tool = tool
        self.points = points.map { PKStrokePointHashWrapper(from: $0) }
    }

}

struct PKStrokePointHashWrapper: DTPoint {

    var location: CGPoint
    var timeOffset: Double
    var altitude: CGFloat
    var azimuth: CGFloat
    var force: CGFloat
    var size: CGSize
    var opacity: CGFloat

    init<P>(from point: P) where P: DTPoint {
        location = point.location
        timeOffset = point.timeOffset
        altitude = point.altitude
        azimuth = point.azimuth
        force = point.force
        size = point.size
        opacity = point.opacity
    }

    init(location: CGPoint, timeOffset: Double, size: CGSize, opacity: CGFloat,
         force: CGFloat, azimuth: CGFloat, altitude: CGFloat) {
        self.location = location
        self.timeOffset = timeOffset
        self.altitude = altitude
        self.azimuth = azimuth
        self.force = force
        self.size = size
        self.opacity = opacity
    }

}
