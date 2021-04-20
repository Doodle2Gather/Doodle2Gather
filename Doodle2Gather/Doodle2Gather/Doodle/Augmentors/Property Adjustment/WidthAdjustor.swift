import CoreGraphics

struct WidthAdjustor: StrokeAugmentor {

    func augmentStroke<S>(_ stroke: S) -> S where S: DTStroke {
        let points = stroke.points
        if points.isEmpty {
            return stroke
        }

        var newPoints = [S.Point]()
        let averageForce = CGFloat(points.map { Double($0.force) }.reduce(0.0, +)
                                    / Double(points.count))
        let averageHeight = CGFloat(points.map { Double($0.size.height) }.reduce(0.0, +)
                                    / Double(points.count))
        let averageWidth = CGFloat(points.map { Double($0.size.width) }.reduce(0.0, +)
                                    / Double(points.count))
        let averageSize = CGSize(width: averageWidth, height: averageHeight)

        for point in points {
            let newPoint = S.Point(location: point.location, timeOffset: point.timeOffset,
                                   size: averageSize, opacity: point.opacity, force: averageForce,
                                   azimuth: 3, altitude: CGFloat.pi / 2)

            newPoints.append(newPoint)
        }

        return S(color: stroke.color, tool: stroke.tool, points: newPoints,
                 transform: stroke.transform, mask: stroke.mask)
    }

}
