import PencilKit

extension PKStrokePoint: DTPoint {
    public init<P>(from point: P) where P: DTPoint {
        self.init(location: point.location, timeOffset: point.timeOffset, size: point.size, opacity: point.opacity,
                  force: point.force, azimuth: point.azimuth, altitude: point.altitude)
    }
}
