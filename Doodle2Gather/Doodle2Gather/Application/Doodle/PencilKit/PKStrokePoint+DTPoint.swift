import PencilKit

/// Adapts `PKStrokePoint` to work with implementations used in Doodle2Gather.
extension PKStrokePoint: DTPoint {

    public init<P>(from point: P) where P: DTPoint {
        self.init(location: point.location, timeOffset: point.timeOffset, size: point.size, opacity: point.opacity,
                  force: point.force, azimuth: point.azimuth, altitude: point.altitude)
    }

}
