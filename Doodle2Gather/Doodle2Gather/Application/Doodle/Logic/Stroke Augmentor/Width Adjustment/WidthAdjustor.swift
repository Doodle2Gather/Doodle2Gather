import CoreGraphics

struct WidthAdjustor: StrokeAugmentor {

    struct AverageableProperties {
        let force: CGFloat
        let size: CGSize
        let azimuth: CGFloat
    }

    func augmentStroke<S>(_ stroke: S) -> S where S: DTStroke {
        let points = stroke.points
        if points.isEmpty {
            return stroke
        }

        let averages = computeAveragePointProperties(points)

        var newPoints = [S.Point]()

        for point in points {
            let newPoint = S.Point(location: point.location, timeOffset: point.timeOffset,
                                   size: averages.size, opacity: point.opacity, force: averages.force,
                                   azimuth: averages.azimuth, altitude: CGFloat.pi / 2)

            newPoints.append(newPoint)
        }

        return S(color: stroke.color, tool: stroke.tool, points: newPoints,
                 transform: stroke.transform, mask: stroke.mask)
    }

    func computeAveragePointProperties<P>(_ points: [P]) -> AverageableProperties where P: DTPoint {
        let averageForce = CGFloat(points.map { Double($0.force) }.reduce(0.0, +)
                                    / Double(points.count))

        let averageHeight = CGFloat(points.map { Double($0.size.height) }.reduce(0.0, +)
                                    / Double(points.count))
        let averageWidth = CGFloat(points.map { Double($0.size.width) }.reduce(0.0, +)
                                    / Double(points.count))
        let averageSize = CGSize(width: averageWidth, height: averageHeight)

        let averageAzimuth = CGFloat(points.map { Double($0.azimuth) }.reduce(0.0, +)
                                        / Double(points.count))

        return AverageableProperties(force: averageForce, size: averageSize, azimuth: averageAzimuth)
    }

}
