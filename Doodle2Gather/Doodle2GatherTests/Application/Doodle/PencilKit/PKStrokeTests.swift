import XCTest
import PencilKit
@testable import Doodle2Gather

class PKStrokeTests: XCTestCase {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func testInit_withDtStroke_isCorrect() {
        let dtStroke = DTAdaptedTestHelper.createTestStroke()

        let stroke = PKStroke(from: dtStroke)

        XCTAssertEqual(stroke.color, dtStroke.color)
        XCTAssertEqual(stroke.tool, dtStroke.tool)
        // Unfortunately, PencilKit does some strange modification of point values
        // So we need to transform all the points into PKStrokePoints first.
        XCTAssertEqual(stroke.points.hashValue, dtStroke.points.map { PKStrokePoint(from: $0) }.hashValue)
        XCTAssertEqual(stroke.mask, dtStroke.mask)
        XCTAssertEqual(stroke.transform, dtStroke.transform)
    }

    func testInit_withAdaptedStroke_isCorrect() throws {
        let adaptedStroke = try DTAdaptedTestHelper.createAdaptedStroke()
        let decodedStroke = try decoder.decode(PKStroke.self, from: adaptedStroke.stroke)

        guard let stroke = PKStroke(from: adaptedStroke) else {
            XCTFail("Should create a stroke")
            return
        }

        XCTAssertEqual(stroke.color, decodedStroke.color)
        XCTAssertEqual(stroke.tool, decodedStroke.tool)
        XCTAssertEqual(stroke.points.hashValue, decodedStroke.points.hashValue)
        XCTAssertEqual(stroke.mask, decodedStroke.mask)
        XCTAssertEqual(stroke.transform, decodedStroke.transform)
    }

    func testInit_withRawValues_isCorrect() throws {
        let points = [
            PencilKitTestHelper.createPoint(),
            PencilKitTestHelper.createPoint(),
            PencilKitTestHelper.createPoint()
        ]
        let transform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
        let mask = UIBezierPath(arcCenter: CGPoint(x: 5, y: 5), radius: 20, startAngle: 0,
                                endAngle: CGFloat.pi / 2, clockwise: true)

        let stroke = PKStroke(color: .blue, tool: .highlighter, points: points, transform: transform, mask: mask)

        XCTAssertEqual(stroke.color, UIColor.blue)
        XCTAssertEqual(stroke.tool, DTCodableTool.highlighter)
        XCTAssertEqual(stroke.points.hashValue, points.hashValue)
        XCTAssertEqual(stroke.transform, transform)
    }

    func testEquatableHashable_sameValues_isEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let strokeTwo = strokeOne

        XCTAssertEqual(strokeOne, strokeTwo)
        XCTAssertEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEquatableHashable_differentColor_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let strokeTwo = PKStroke(color: strokeOne.color.lighten(),
                                 tool: strokeOne.tool,
                                 points: strokeOne.points,
                                 transform: strokeOne.transform,
                                 mask: strokeOne.mask)

        XCTAssertNotEqual(strokeOne, strokeTwo)
        XCTAssertNotEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEquatableHashable_differentTool_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let strokeTwo = PKStroke(color: strokeOne.color,
                                 tool: strokeOne.tool == .highlighter ? .pen : .highlighter,
                                 points: strokeOne.points,
                                 transform: strokeOne.transform,
                                 mask: strokeOne.mask)

        XCTAssertNotEqual(strokeOne, strokeTwo)
        XCTAssertNotEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEquatableHashable_differentPoints_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let points = strokeOne.points + [PencilKitTestHelper.createPoint()]
        let strokeTwo = PKStroke(color: strokeOne.color,
                                 tool: strokeOne.tool,
                                 points: points,
                                 transform: strokeOne.transform,
                                 mask: strokeOne.mask)

        XCTAssertNotEqual(strokeOne, strokeTwo)
        XCTAssertNotEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEquatableHashable_differentTransform_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let transform = CGAffineTransform(a: strokeOne.transform.a + 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
        let strokeTwo = PKStroke(color: strokeOne.color,
                                 tool: strokeOne.tool,
                                 points: strokeOne.points,
                                 transform: transform,
                                 mask: strokeOne.mask)

        XCTAssertNotEqual(strokeOne, strokeTwo)
        XCTAssertNotEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEquatableHashable_differentMask_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let mask = UIBezierPath(arcCenter: CGPoint(x: 5, y: 5), radius: 20, startAngle: 0,
                                endAngle: CGFloat.pi / 2, clockwise: true)
        let strokeTwo = PKStroke(color: strokeOne.color,
                                 tool: strokeOne.tool,
                                 points: strokeOne.points,
                                 transform: strokeOne.transform,
                                 mask: mask)

        XCTAssertNotEqual(strokeOne, strokeTwo)
        XCTAssertNotEqual(strokeOne.hashValue, strokeTwo.hashValue)
    }

    func testEncodable_sameStroke() throws {
        let originalStroke = PencilKitTestHelper.createStroke()
        let data = try encoder.encode(originalStroke)
        let decodedStroke = try decoder.decode(PKStroke.self, from: data)
        XCTAssertEqual(originalStroke, decodedStroke)
    }

}
