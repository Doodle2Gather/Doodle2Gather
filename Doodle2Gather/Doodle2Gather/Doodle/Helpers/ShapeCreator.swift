import UIKit

struct ShapeCreator {

    enum Constants {
        // Shape properties
        static let circleRadius: CGFloat = 100
        static let squareLength: CGFloat = 100
        static let triangleLength: CGFloat = 100

        // Point properties
        static let pointDensity: Int = 30
        static let maxTimeOffset: Double = 1.0
        static let defaultForce: CGFloat = 0
        static let defaultSize = CGSize(width: 10, height: 10)
        static let defaultOpacity: CGFloat = 1
        static let defaultAzimuth: CGFloat = -1.5
        static let defaultAltitude = CGFloat.pi / 2

        // Stroke properties
        static let defaultTransform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        static let defaultTool: DTCodableTool = .pen
        static let defaultColor: UIColor = .black
    }

    func createCircle<S: DTStroke>(center: CGPoint) -> S {
        var points = [S.Point]()

        for i in 0..<Constants.pointDensity {
            let ratio = Double(i) / Double(Constants.pointDensity)
            let angle = Double.pi * ratio
            let x = CGFloat(cos(angle)) * Constants.circleRadius + center.x
            let y = CGFloat(sin(angle)) * Constants.circleRadius + center.y

            let point = S.Point(location: CGPoint(x: x, y: y),
                                timeOffset: Constants.maxTimeOffset * ratio,
                                size: Constants.defaultSize, opacity: Constants.defaultOpacity,
                                force: Constants.defaultForce, azimuth: Constants.defaultAzimuth,
                                altitude: Constants.defaultAltitude)
            points.append(point)
        }

        return S(color: Constants.defaultColor, tool: Constants.defaultTool, points: points,
                 transform: Constants.defaultTransform, mask: nil)
    }

}
