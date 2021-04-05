import UIKit
import DTFrontendLibrary

struct PKStrokeHashWrapper: DTStroke {

    var color: UIColor
    var tool: DTTool
    var points: [PKStrokePointHashWrapper]
    // var mask: UIBezierPath?
    // var transform: CGAffineTransform

    init<S>(from stroke: S) where S: DTStroke {
        self.color = stroke.color
        self.tool = stroke.tool
        self.points = stroke.points.map { PKStrokePointHashWrapper(from: $0) }
        // self.mask = stroke.mask
        // self.transform = stroke.transform
    }

    init<P>(color: UIColor, tool: DTTool, points: [P]
            // transform: CGAffineTransform, mask: UIBezierPath?
    ) where P: DTPoint {
        self.color = color
        self.tool = tool
        self.points = points.map { PKStrokePointHashWrapper(from: $0) }
        // self.transform = transform
        // self.mask = mask
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
