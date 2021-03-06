import CoreGraphics

/// Detects shapes using Hough Transform.
///
/// - Important: This detector is quite inaccurate, likely due to the fact
///   that it's designed to work better with pixels rather than singular points
///   like that of strokes. The default implementation uses
///   `BestFitShapeDetector` instead.
struct HoughShapeDetector: StrokeAugmentor {

    typealias Vector = [Double]
    typealias Matrix = [Vector]

    struct Line {
        var theta: Int
        var distance: Int
        var occurrence: Int
    }

    func augmentStroke<S>(_ stroke: S) -> S where S: DTStroke {
        guard !stroke.points.isEmpty, let firstPoint = stroke.points.first,
              let lastPoint = stroke.points.last else {
            return stroke
        }
        let locations = stroke.points.map { $0.location }

        guard let minX = locations.map({ $0.x }).min(), let minY = locations.map({ $0.y }).min() else {
            return stroke
        }

        let houghSpace = createHoughSpace(from: stroke)
        guard let line = getTopLine(of: houghSpace) else {
            return stroke
        }

        let rtheta = Double(line.theta) * Double.pi / 180
        let slope = -(cos(rtheta) / sin(rtheta))
        let intercept = Double(line.distance) * (1 / sin(rtheta))

        let lineEquation = { (x: CGFloat) in
            CGFloat(slope * Double(x) + intercept)
        }

        let startX = firstPoint.location.x - minX
        let startY = lineEquation(startX)
        let endX = lastPoint.location.x - minX
        let endY = lineEquation(endX)

        let finalStroke = S(color: stroke.color, tool: stroke.tool, points: [
            S.Point(location: CGPoint(x: startX + minX, y: -startY + minY), timeOffset: firstPoint.timeOffset,
                    size: firstPoint.size, opacity: firstPoint.opacity, force: firstPoint.force,
                    azimuth: firstPoint.azimuth, altitude: firstPoint.altitude),
            S.Point(location: CGPoint(x: endX + minX, y: -endY + minY), timeOffset: lastPoint.timeOffset,
                    size: lastPoint.size, opacity: lastPoint.opacity, force: lastPoint.force,
                    azimuth: lastPoint.azimuth, altitude: lastPoint.altitude)
        ], transform: stroke.transform, mask: stroke.mask)

        return finalStroke
    }

    // MARK: - Matrix

    /// Creates an empty Hough matrix.
    private func createEmptyMatrix(height: Int, width: Int) -> Matrix {
        Matrix(repeating: Vector(repeating: 0, count: width), count: height)
    }

    /// Gets the size of a given matrix.
    private func getSize(of matrix: Matrix) -> (height: Int, width: Int) {
        if matrix.isEmpty {
            return (height: 0, width: 0)
        }

        let firstRow = matrix[0]
        return (height: matrix.count, width: firstRow.count)
    }

    // MARK: - DTStroke

    /// Computes the Hough space dimensions for a given stroke.
    ///
    /// The formula is height = 180, width = sqrt(diffX^2 + diffY^2), where diffX and diffY
    /// are the differences between min and max of X and Y respectively.
    private func getHoughSpaceDimensions<S>(of stroke: S) -> (height: Int, width: Int) where S: DTStroke {
        let points = stroke.points
        let locations = points.map { $0.location }
        guard let minX = locations.map({ $0.x }).min(), let minY = locations.map({ $0.y }).min(),
              let maxX = locations.map({ $0.x }).max(), let maxY = locations.map({ $0.y }).max() else {
            return (height: 0, width: 0)
        }

        let longestDistance = sqrt(pow(maxX - minX, 2) + pow(maxY - minY, 2))
        return (height: 180, width: Int(ceil(longestDistance)))
    }

    // MARK: - Hough Transform

    /// Generates a Hough space from a given stroke.
    private func createHoughSpace<S>(from stroke: S) -> Matrix where S: DTStroke {
        let (height, width) = getHoughSpaceDimensions(of: stroke)
        let points = stroke.points
        let locations = points.map { $0.location }
        var space = createEmptyMatrix(height: height, width: width)

        guard let minX = locations.map({ $0.x }).min(), let minY = locations.map({ $0.y }).min() else {
            return space
        }

        for point in points {
            let location = point.location
            let x = location.x - minX
            let y = location.y - minY
            for theta in 0..<180 {
                let rtheta = Double(theta) * Double.pi / 180
                let distance = Double(y) * cos(rtheta) - Double(x) * sin(rtheta)
                if distance >= 1 {
                    space[theta][Int(distance)] += 1
                }
            }
        }

        return space
    }

    /// Gets the most frequently occurring line within the Hough space.
    private func getTopLine(of houghSpace: Matrix) -> Line? {
        let (height, width) = getSize(of: houghSpace)

        var lines: [Line] = [Line](
            repeating: Line(theta: 0, distance: 0, occurrence: 0),
            count: height * width
        )

        for (i, row) in houghSpace.enumerated() {
            for j in row.indices {
                let occurrence = houghSpace[i][j]

                lines[i * width + j] = Line(theta: i, distance: j, occurrence: Int(occurrence))
            }
        }

        let sortedLines = lines.sorted { a, b in
            a.occurrence < b.occurrence
        }

        return sortedLines.last
    }

}
