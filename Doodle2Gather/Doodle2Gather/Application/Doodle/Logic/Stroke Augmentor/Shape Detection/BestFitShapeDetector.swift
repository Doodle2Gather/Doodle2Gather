import CoreGraphics

/// A shape detector that uses lines and shapes of best fit to identify
/// shapes.
///
/// Works better than `HoughShapeDetector` for sparse points.
struct BestFitShapeDetector: StrokeAugmentor {

    enum Constants {
        static let lineErrorThreshold: CGFloat = 2_000
        static let circleErrorThreshold: CGFloat = 100
    }

    func augmentStroke<S>(_ stroke: S) -> S where S: DTStroke {
        var pointLocations = stroke.points.map { $0.location }
        guard let minX = pointLocations.map({ $0.x }).min(),
              let minY = pointLocations.map({ $0.y }).min() else {
            return stroke
        }
        pointLocations = pointLocations.map { CGPoint(x: $0.x - minX, y: $0.y - minY) }

        var bestFitPoints: [CGPoint]?

        bestFitPoints = computeLineOfBestFit(for: pointLocations)
        if bestFitPoints == nil {
            bestFitPoints = computeCircleOfBestFit(for: pointLocations)
        }

        guard let finalPoints = bestFitPoints else {
            return stroke
        }

        var points = [S.Point]()

        for (index, point) in finalPoints.enumerated() {
            if index >= stroke.points.count {
                break
            }
            let originalPoint = stroke.points[index]
            let point = CGPoint(x: point.x + minX, y: point.y + minY)

            points.append(S.Point(location: point, timeOffset: originalPoint.timeOffset,
                                  size: originalPoint.size, opacity: originalPoint.opacity,
                                  force: originalPoint.force, azimuth: originalPoint.azimuth,
                                  altitude: originalPoint.altitude))
        }

        return S(color: stroke.color, tool: stroke.tool, points: points, transform: stroke.transform, mask: stroke.mask)
    }

    /// Helps to check if a float is sufficiently close to zero.
    private func isZero(_ f: CGFloat) -> Bool {
        let epsilon: CGFloat = 0.000_01
        return abs(f) < epsilon
    }

}

// MARK: - Line Check

extension BestFitShapeDetector {

    /// Checks if the points form a line.
    /// Adapted from https://stackoverflow.com/a/52127714
    private func computeLineOfBestFit(for points: [CGPoint]) -> [CGPoint]? {
        // Variables for computing linear regression
        var sumXX: CGFloat = 0  // sum of X^2
        var sumXY: CGFloat = 0  // sum of X * Y
        var sumX: CGFloat = 0  // sum of X
        var sumY: CGFloat = 0  // sum of Y

        for point in points {
            sumXX += point.x * point.x
            sumXY += point.x * point.y
            sumX += point.x
            sumY += point.y
        }

        let numPoints = CGFloat(points.count)

        // Compute numerator and denominator of the gradient
        let numerator = numPoints * sumXY - sumX * sumY
        let denominator = numPoints * sumXX - sumX * sumX

        // Line is horizontal
        if isZero(numerator) {
            let avgY = sumY / numPoints
            return points.map { CGPoint(x: $0.x, y: avgY) }
        }

        // Line is vertical
        if isZero(denominator) {
            let avgX = sumX / numPoints
            return points.map { CGPoint(x: avgX, y: $0.y) }
        }

        // Calculate slope of line
        let gradient = numerator / denominator
        // Calculate the y-intercept
        let intercept = (sumY - gradient * sumX) / numPoints

        // Check fit by summing the squares of the errors
        var error: CGFloat = 0
        var bestFitPoints = [CGPoint]()
        for point in points {
            // Apply equation of line y = mx + b to compute predicted y
            let predictedY = gradient * point.x + intercept
            error += pow(predictedY - point.y, 2)

            bestFitPoints.append(CGPoint(x: point.x, y: predictedY))
        }

        let distX = abs(points[0].x - points[points.count - 1].x)
        let distY = abs(points[0].y - points[points.count - 1].y)

        let distance = sqrt(distX * distX + distY * distY)

        // Not a line
        if error > distance * Constants.lineErrorThreshold {
            return nil
        }

        return bestFitPoints
    }

}

// MARK: - Circle Check

extension BestFitShapeDetector {

    /// Checks if the points form a circle, and returns the adjusted points.
    private func computeCircleOfBestFit(for points: [CGPoint]) -> [CGPoint]? {
        if points.isEmpty {
            return nil
        }
        guard let center = initializeTriplets(for: points),
              let radius = computeRadius(center: center, points: points) else {
            return nil
        }

        // Check fit by summing the squares of the errors
        var error: CGFloat = 0
        var bestFitPoints = [CGPoint]()
        for point in points {
            let distX = point.x - center.x
            let distY = point.y - center.y
            error += distX * distX + distY * distY

            let theta = atan2(distY, distX)
            bestFitPoints.append(CGPoint(x: center.x + radius * cos(theta),
                                         y: center.y + radius * sin(theta)))
        }

        if error > radius * radius * Constants.circleErrorThreshold {
            return nil
        }

        return bestFitPoints
    }

    private func initializeTriplets(for points: [CGPoint]) -> CGPoint? {
        var center = CGPoint(x: 0, y: 0)
        var numCircumcenters = 0
        let numPoints = points.count

        if numPoints < 3 {
            return nil
        }

        for i in 0..<(numPoints - 2) {
            let p1 = points[i]
            for j in (i + 1)..<(numPoints - 1) {
                let p2 = points[j]
                for k in (j + 1)..<numPoints {
                    let p3 = points[k]

                    // Compute the triangle circumcenter
                    let circumcenter = computeCircumcenter(p1: p1, p2: p2, p3: p3)

                    if let circumcenter = circumcenter {
                        numCircumcenters += 1
                        center.x += circumcenter.x
                        center.y += circumcenter.y
                    }
                }
            }
        }

        // All points are aligned
        if numCircumcenters == 0 {
            return nil
        }

        // Compute the average center
        center.x /= CGFloat(numCircumcenters)
        center.y /= CGFloat(numCircumcenters)

        return center
    }

    private func computeCircumcenter(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint? {
        // Compute helper variables
        let d12 = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let d23 = CGPoint(x: p3.x - p2.x, y: p3.y - p2.y)
        let d31 = CGPoint(x: p1.x - p3.x, y: p1.y - p3.y)
        let sq1 = p1.x * p1.x + p1.y * p1.y
        let sq2 = p2.x * p2.x + p2.y * p2.y
        let sq3 = p3.x * p3.x + p3.y * p3.y

        // Determinant of the linear system: 0 for aligned points
        let det = d23.x * d12.y - d12.x * d23.y

        if isZero(det) {
            // Points are almost aligned, we cannot compute the circumcenter
            return nil
        }

        return CGPoint(
            x: (sq1 * d23.y + sq2 * d31.y + sq3 * d12.y) / (2 * det),
            y: -(sq1 * d23.x + sq2 * d31.x + sq3 * d12.x) / (2 * det)
        )
    }

    private func computeRadius(center: CGPoint, points: [CGPoint]) -> CGFloat? {
        if points.isEmpty {
            return nil
        }
        var radius: CGFloat = 0
        for i in 0..<points.count {
            let dx = points[i].x - center.x
            let dy = points[i].y - center.y
            radius += sqrt(dx * dx + dy * dy)
        }
        radius /= CGFloat(points.count)
        return radius
    }

}
