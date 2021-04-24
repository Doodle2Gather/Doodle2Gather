import PencilKit
import XCTest
@testable import Doodle2Gather

struct PencilKitTestHelper {

    static func createPoint() -> PKStrokePoint {
        PKStrokePoint(location: CGPoint(x: CGFloat.random(in: 0...500), y: CGFloat.random(in: 0...500)),
                      timeOffset: Double.random(in: 0...2),
                      size: CGSize(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15)),
                      opacity: CGFloat.random(in: 0.1...1),
                      force: CGFloat.random(in: 0...1),
                      azimuth: CGFloat.random(in: -CGFloat.pi...CGFloat.pi),
                      altitude: CGFloat.random(in: 0...(CGFloat.pi / 2)))
    }

    static func createStroke(numberOfPoints: Int = 10) -> PKStroke {
        var points = [PKStrokePoint]()
        for _ in 0..<numberOfPoints {
            points.append(createPoint())
        }
        return PKStroke(color: UIColor(displayP3Red: CGFloat.random(in: 0...1),
                                       green: CGFloat.random(in: 0...1),
                                       blue: CGFloat.random(in: 0...1),
                                       alpha: CGFloat.random(in: 0...1)),
                        tool: [DTCodableTool.pen, DTCodableTool.highlighter, DTCodableTool.pencil].randomElement()!,
                        points: points,
                        transform: DoodleConstants.defaultTransform,
                        mask: nil)
    }

    static func createDrawing(numberOfStrokes: Int = 10) -> PKDrawing {
        var strokes = [PKStroke]()
        for _ in 0..<numberOfStrokes {
            strokes.append(createStroke())
        }
        return PKDrawing(strokes: strokes)
    }

    static func XCTAssertApprox(_ value1: Double, _ value2: Double) {
        XCTAssertEqual(value1, value2, accuracy: 0.1)
    }

    static func XCTAssertApprox(_ value1: CGFloat, _ value2: CGFloat) {
        XCTAssertEqual(value1, value2, accuracy: 0.1)
    }

    static func XCTAssertApprox(_ value1: CGPoint, _ value2: CGPoint) {
        XCTAssertEqual(value1.x, value2.x, accuracy: 0.1)
        XCTAssertEqual(value1.y, value2.y, accuracy: 0.1)
    }

    static func XCTAssertApprox(_ value1: CGSize, _ value2: CGSize) {
        XCTAssertEqual(value1.height, value2.height, accuracy: 0.1)
        XCTAssertEqual(value1.width, value2.width, accuracy: 0.1)
    }

}
