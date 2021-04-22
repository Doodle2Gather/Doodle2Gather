import XCTest
import PencilKit
@testable import Doodle2Gather

class DTStrokeWrapperTests: XCTestCase {

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func testInit_PKStrokeAndCreatedBy_isCorrect() {
        let pkStroke = PencilKitTestHelper.createStroke()
        let stroke = DTStrokeWrapper(stroke: pkStroke, createdBy: "userString")

        XCTAssertFalse(stroke.isDeleted)
        XCTAssertEqual(stroke.createdBy, "userString")
        XCTAssertEqual(stroke.stroke, pkStroke)
    }

    func testInit_PKStrokeAndAllFields_isCorrect() {
        let pkStroke = PencilKitTestHelper.createStroke()
        let strokeId = UUID()
        let stroke = DTStrokeWrapper(stroke: pkStroke, strokeId: strokeId, createdBy: "userString", isDeleted: true)

        XCTAssert(stroke.isDeleted)
        XCTAssertEqual(stroke.createdBy, "userString")
        XCTAssertEqual(stroke.strokeId, strokeId)
        XCTAssertEqual(stroke.stroke, pkStroke)
    }

    func testInit_adaptedStroke_isCorrect() throws {
        let adaptedStroke = try DTAdaptedTestHelper.createAdaptedStroke()
        let stroke = try XCTUnwrap(DTStrokeWrapper(stroke: adaptedStroke))

        // let decodedStroke = try decoder.decode(PKStroke.self, from: adaptedStroke.stroke)

        XCTAssertEqual(stroke.isDeleted, adaptedStroke.isDeleted)
        XCTAssertEqual(stroke.createdBy, adaptedStroke.createdBy)
        XCTAssertEqual(stroke.strokeId, adaptedStroke.strokeId)

        // TODO: Debug this
        // XCTAssertEqual(stroke.stroke, decodedStroke)
    }

    func testInit_data_isCorrect() throws {
        let pkStroke = PencilKitTestHelper.createStroke()
        let data = try encoder.encode(pkStroke)
        let strokeId = UUID()

        let stroke = try XCTUnwrap(DTStrokeWrapper(data: data, strokeId: strokeId,
                                                   createdBy: "userString", isDeleted: true))

        XCTAssert(stroke.isDeleted)
        XCTAssertEqual(stroke.createdBy, "userString")
        XCTAssertEqual(stroke.strokeId, strokeId)
        // TODO: Debug this
        // XCTAssertEqual(stroke.stroke, pkStroke)
    }

    func testEquatable_sameStrokeWrapper_isEqual() {
        let stroke = PencilKitTestHelper.createStroke()
        let strokeId = UUID()

        let wrapperOne = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: false)
        let wrapperTwo = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: false)

        XCTAssertEqual(wrapperOne, wrapperTwo)
    }

    func testEquatable_differentStrokeId_isNotEqual() {
        let stroke = PencilKitTestHelper.createStroke()
        let strokeIdOne = UUID()
        let strokeIdTwo = UUID()

        let wrapperOne = DTStrokeWrapper(stroke: stroke, strokeId: strokeIdOne,
                                         createdBy: "userString", isDeleted: false)
        let wrapperTwo = DTStrokeWrapper(stroke: stroke, strokeId: strokeIdTwo,
                                         createdBy: "userString", isDeleted: false)

        XCTAssertNotEqual(wrapperOne, wrapperTwo)
    }

    func testEquatable_differentCreatedBy_isNotEqual() {
        let stroke = PencilKitTestHelper.createStroke()
        let strokeId = UUID()

        let wrapperOne = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userStringOne", isDeleted: false)
        let wrapperTwo = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userStringTwo", isDeleted: false)

        XCTAssertNotEqual(wrapperOne, wrapperTwo)
    }

    func testEquatable_differentIsDeleted_isNotEqual() {
        let stroke = PencilKitTestHelper.createStroke()
        let strokeId = UUID()

        let wrapperOne = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: false)
        let wrapperTwo = DTStrokeWrapper(stroke: stroke, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: true)

        XCTAssertNotEqual(wrapperOne, wrapperTwo)
    }

    func testEquatable_differentStroke_isNotEqual() {
        let strokeOne = PencilKitTestHelper.createStroke()
        let strokeTwo = PencilKitTestHelper.createStroke()
        let strokeId = UUID()

        let wrapperOne = DTStrokeWrapper(stroke: strokeOne, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: false)
        let wrapperTwo = DTStrokeWrapper(stroke: strokeTwo, strokeId: strokeId,
                                         createdBy: "userString", isDeleted: false)

        XCTAssertNotEqual(wrapperOne, wrapperTwo)
    }

}
