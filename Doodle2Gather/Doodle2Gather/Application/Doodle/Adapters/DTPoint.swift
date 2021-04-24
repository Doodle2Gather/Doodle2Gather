import CoreGraphics

/// Represents a single point that's contained in a stroke.
///
/// By adopting this protocol, any point model can replace `PKStrokePoint`
/// in the current implementation.
///
/// - Note: This protocol is modeled after PencilKit's PKStrokePoint, but is
///   designed for further extensions in the future.
public protocol DTPoint: Hashable, Codable {

    /// The position of the point.
    var location: CGPoint { get }

    /// The duration at which this point was plotted since the
    /// start of the doodling motion.
    var timeOffset: Double { get }

    /// Touch data provided by the Apple Pencil.
    var altitude: CGFloat { get }
    var azimuth: CGFloat { get }
    var force: CGFloat { get }

    /// Initial size of the point, without accounting for touch data.
    var size: CGSize { get }

    /// Opacity of the point.
    var opacity: CGFloat { get }

    /// Initialises the `DTPoint` instance.
    init(location: CGPoint, timeOffset: Double, size: CGSize, opacity: CGFloat, force: CGFloat,
         azimuth: CGFloat, altitude: CGFloat)

    /// Instantiates self using a generalised `DTPoint`.
    init<P: DTPoint>(from point: P)

}

// MARK: - Equatable

extension DTPoint {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.location.x.round(to: DoodleConstants.accuracy) == rhs.location.x.round(to: DoodleConstants.accuracy)
            && lhs.location.y.round(to: DoodleConstants.accuracy)
            == rhs.location.y.round(to: DoodleConstants.accuracy)
            && lhs.timeOffset.round(to: DoodleConstants.accuracy)
            == rhs.timeOffset.round(to: DoodleConstants.accuracy)
            && lhs.altitude.round(to: DoodleConstants.accuracy)
            == rhs.altitude.round(to: DoodleConstants.accuracy)
            && lhs.azimuth.round(to: DoodleConstants.accuracy) == rhs.azimuth.round(to: DoodleConstants.accuracy)
            && lhs.force.round(to: DoodleConstants.accuracy) == rhs.force.round(to: DoodleConstants.accuracy)
            && lhs.size.height.round(to: DoodleConstants.accuracy)
            == rhs.size.height.round(to: DoodleConstants.accuracy)
            && lhs.size.width.round(to: DoodleConstants.accuracy)
            == rhs.size.width.round(to: DoodleConstants.accuracy)
            && lhs.opacity.round(to: DoodleConstants.accuracy) == rhs.opacity.round(to: DoodleConstants.accuracy)
    }

}

// MARK: - Hashable

extension DTPoint {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(location.x.round(to: DoodleConstants.accuracy))
        hasher.combine(location.y.round(to: DoodleConstants.accuracy))
        hasher.combine(timeOffset.round(to: DoodleConstants.accuracy))
        hasher.combine(altitude.round(to: DoodleConstants.accuracy))
        hasher.combine(azimuth.round(to: DoodleConstants.accuracy))
        hasher.combine(force.round(to: DoodleConstants.accuracy))
        hasher.combine(size.height.round(to: DoodleConstants.accuracy))
        hasher.combine(size.width.round(to: DoodleConstants.accuracy))
        hasher.combine(opacity.round(to: DoodleConstants.accuracy))
    }

}

// MARK: - Codable

extension DTPoint {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DTPointCodingKeys.self)
        try container.encode(location.round(to: DoodleConstants.accuracy), forKey: .location)
        try container.encode(timeOffset.round(to: DoodleConstants.accuracy), forKey: .timeOffset)
        try container.encode(altitude.round(to: DoodleConstants.accuracy), forKey: .altitude)
        try container.encode(azimuth.round(to: DoodleConstants.accuracy), forKey: .azimuth)
        try container.encode(force.round(to: DoodleConstants.accuracy), forKey: .force)
        try container.encode(size.round(to: DoodleConstants.accuracy), forKey: .size)
        try container.encode(opacity.round(to: DoodleConstants.accuracy), forKey: .opacity)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DTPointCodingKeys.self)
        let location = try container.decode(CGPoint.self, forKey: .location)
        let timeOffset = try container.decode(Double.self, forKey: .timeOffset)
        let altitude = try container.decode(CGFloat.self, forKey: .altitude)
        let azimuth = try container.decode(CGFloat.self, forKey: .azimuth)
        let force = try container.decode(CGFloat.self, forKey: .force)
        let size = try container.decode(CGSize.self, forKey: .size)
        let opacity = try container.decode(CGFloat.self, forKey: .opacity)

        self.init(location: location, timeOffset: timeOffset, size: size, opacity: opacity,
                  force: force, azimuth: azimuth, altitude: altitude)
    }

}

/// Keys for encoding and decoding `DTStroke`.
enum DTPointCodingKeys: CodingKey {
    case location
    case timeOffset
    case altitude
    case azimuth
    case force
    case size
    case opacity
}
