import UIKit

struct ShapeCreator {

    enum Constants {
        // Shape properties
        static let circleRadius: CGFloat = 100
        static let squareLength: CGFloat = 200
        static let triangleDistance: CGFloat = 133
        static let starDistance: CGFloat = 110

        // Point properties
        static let pointDensity: Int = 30
        static let maxTimeOffset: Double = 1.0
        static let defaultForce: CGFloat = 0
        static let defaultSize = CGSize(width: 6, height: 6)
        static let defaultOpacity: CGFloat = 1
        static let defaultAzimuth: CGFloat = -1.5
        static let defaultAltitude = CGFloat.pi / 2

        // Stroke properties
        static let defaultTransform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        static let defaultTool: DTCodableTool = .pen
        static let defaultColor: UIColor = .black
    }

    /// Creates a circle stroke centered at a given `center`.
    func createCircle<S: DTStroke>(center: CGPoint) -> S {
        var points = [S.Point]()

        for i in 0...Constants.pointDensity {
            let ratio = Double(i) / Double(Constants.pointDensity)
            let angle = 2 * Double.pi * ratio
            let x = CGFloat(cos(angle)) * Constants.circleRadius + center.x
            let y = CGFloat(sin(angle)) * Constants.circleRadius + center.y

            let point: S.Point = createPoint(at: CGPoint(x: x, y: y), timeOffset: Constants.maxTimeOffset * ratio)
            points.append(point)
        }

        return S(color: Constants.defaultColor, tool: Constants.defaultTool, points: points,
                 transform: Constants.defaultTransform, mask: nil)
    }

    /// Creates a square stroke centered at a given `center`.
    func createSquare<S: DTStroke>(center: CGPoint) -> S {
        let topLeftCorner = CGPoint(x: center.x - Constants.squareLength / 2,
                                    y: center.y - Constants.squareLength / 2)
        let topRightCorner = CGPoint(x: center.x + Constants.squareLength / 2,
                                     y: center.y - Constants.squareLength / 2)
        let bottomRightCorner = CGPoint(x: center.x + Constants.squareLength / 2,
                                        y: center.y + Constants.squareLength / 2)
        let bottomLeftCorner = CGPoint(x: center.x - Constants.squareLength / 2,
                                       y: center.y + Constants.squareLength / 2)

        let points: [S.Point] = createPointsBetweenCorners(corners: [topLeftCorner, topRightCorner,
                                                                     bottomRightCorner, bottomLeftCorner])

        return S(color: Constants.defaultColor, tool: Constants.defaultTool, points: points,
                 transform: Constants.defaultTransform, mask: nil)
    }

    /// Creates a triangle stroke centered at a given `center`.
    func createTriangle<S: DTStroke>(center: CGPoint) -> S {
        let topCorner = CGPoint(x: center.x, y: center.y - Constants.triangleDistance)

        let yDifference = CGFloat(sin(Double.pi / 6)) * Constants.triangleDistance
        let xDifference = CGFloat(cos(Double.pi / 6)) * Constants.triangleDistance

        let leftCorner = CGPoint(x: center.x - xDifference, y: center.y + yDifference)
        let rightCorner = CGPoint(x: center.x + xDifference, y: center.y + yDifference)
        let corners = [topCorner, rightCorner, leftCorner]

        let points: [S.Point] = createPointsBetweenCorners(corners: corners)

        return S(color: Constants.defaultColor, tool: Constants.defaultTool, points: points,
                 transform: Constants.defaultTransform, mask: nil)
    }

    /// Creates a star stroke centered at a given `center`.
    func createStar<S: DTStroke>(center: CGPoint) -> S {
        var corners = [CGPoint]()

        for i in 0..<10 {
            let distanceOfPoint = i.isMultiple(of: 2) ? Constants.starDistance : Constants.starDistance / 3
            let angle = (Double.pi / 5) * Double(i) - (Double.pi / 2)
            let yDiff = CGFloat(sin(angle) * Double(distanceOfPoint))
            let xDiff = CGFloat(cos(angle) * Double(distanceOfPoint))
            corners.append(CGPoint(x: center.x + xDiff, y: center.y + yDiff))
        }

        let points: [S.Point] = createPointsBetweenCorners(corners: corners)

        return S(color: Constants.defaultColor, tool: Constants.defaultTool, points: points,
                 transform: Constants.defaultTransform, mask: nil)
    }

    private func createPoint<P: DTPoint>(at location: CGPoint, timeOffset: Double) -> P {
        P(location: location, timeOffset: timeOffset, size: Constants.defaultSize,
          opacity: Constants.defaultOpacity, force: Constants.defaultForce,
          azimuth: Constants.defaultAzimuth, altitude: Constants.defaultAltitude)
    }

    private func createPointsBetweenCorners<P: DTPoint>(corners: [CGPoint]) -> [P] {
        let numberOfPointsPerEdge = Int(ceil(Double(Constants.pointDensity) / Double(corners.count)))

        var points = [P]()

        for i in 0..<corners.count {
            let firstCorner = corners[i]
            let secondCorner = corners[(i + 1) % corners.count]

            let xDiff = secondCorner.x - firstCorner.x
            let yDiff = secondCorner.y - firstCorner.y

            for j in 0..<numberOfPointsPerEdge {
                let ratio = CGFloat(j % numberOfPointsPerEdge) / CGFloat(numberOfPointsPerEdge - 1)
                let currentLocation = CGPoint(x: firstCorner.x + (xDiff * ratio),
                                              y: firstCorner.y + (yDiff * ratio))
                let overallRatio = Double(i * numberOfPointsPerEdge + j) / Double(numberOfPointsPerEdge * corners.count)
                let point: P = createPoint(at: currentLocation, timeOffset: Constants.maxTimeOffset * overallRatio)
                points.append(point)
            }
        }

        return points
    }

}
