import Doodle2Gather
import CoreGraphics

struct TestPoint: DTPoint {

    var location: CGPoint
    var timeOffset: Double
    var altitude: CGFloat
    var azimuth: CGFloat
    var force: CGFloat
    var size: CGSize
    var opacity: CGFloat

    init(location: CGPoint, timeOffset: Double, size: CGSize, opacity: CGFloat,
         force: CGFloat, azimuth: CGFloat, altitude: CGFloat) {
        self.location = location
        self.timeOffset = timeOffset
        self.size = size
        self.opacity = opacity
        self.force = force
        self.azimuth = azimuth
        self.altitude = altitude
    }

    init<P>(from point: P) where P: DTPoint {
        location = point.location
        timeOffset = point.timeOffset
        size = point.size
        opacity = point.opacity
        force = point.force
        azimuth = point.azimuth
        altitude = point.altitude
    }
}
