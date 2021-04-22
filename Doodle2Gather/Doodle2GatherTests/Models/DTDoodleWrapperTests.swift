import XCTest
@testable import Doodle2Gather

class DTDoodleWrapperTests: XCTestCase {

    func testStrokesDidSet_appendUndeletedStroke_addsStrokeToDrawing() {
        var doodle = DTDoodleWrapper()
        let stroke = DTAdaptedTestHelper.createStrokeWrapper()

        XCTAssert(doodle.strokes.isEmpty)
        XCTAssert(doodle.drawing.dtStrokes.isEmpty)
        doodle.strokes.append(stroke)

        XCTAssertEqual(doodle.strokes.count, 1)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 1)
        XCTAssertEqual(doodle.strokes[0].stroke, doodle.drawing.dtStrokes[0])
    }

    func testStrokesDidSet_appendDeletedStroke_doesNotAddStrokeToDrawing() {
        var doodle = DTDoodleWrapper()
        let stroke = DTAdaptedTestHelper.createStrokeWrapper(isDeleted: true)

        XCTAssert(doodle.strokes.isEmpty)
        XCTAssert(doodle.drawing.dtStrokes.isEmpty)
        doodle.strokes.append(stroke)

        XCTAssertEqual(doodle.strokes.count, 1)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 0)
    }

    func testStrokesDidSet_removeUndeletedStroke_removesStrokeFromDrawing() {
        var doodle = DTDoodleWrapper()
        let strokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        let strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        let strokeThree = DTAdaptedTestHelper.createStrokeWrapper()

        doodle.strokes = [strokeOne, strokeTwo, strokeThree]

        XCTAssertEqual(doodle.strokes.count, 3)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 3)
        XCTAssertEqual(doodle.strokes.map { $0.stroke }, doodle.drawing.dtStrokes)

        doodle.strokes.remove(at: 1)

        XCTAssertEqual(doodle.strokes.count, 2)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 2)
        XCTAssertEqual(doodle.strokes.map { $0.stroke }, doodle.drawing.dtStrokes)
    }

    func testStrokesDidSet_removeDeletedStroke_noChangeToDrawing() {
        var doodle = DTDoodleWrapper()
        let strokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        let strokeTwo = DTAdaptedTestHelper.createStrokeWrapper(isDeleted: true)
        let strokeThree = DTAdaptedTestHelper.createStrokeWrapper()

        doodle.strokes = [strokeOne, strokeTwo, strokeThree]

        XCTAssertEqual(doodle.strokes.count, 3)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 2)
        XCTAssertEqual(doodle.strokes.filter { !$0.isDeleted }.map { $0.stroke }, doodle.drawing.dtStrokes)

        doodle.strokes.remove(at: 1)

        XCTAssertEqual(doodle.strokes.count, 2)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 2)
        XCTAssertEqual(doodle.strokes.map { $0.stroke }, doodle.drawing.dtStrokes)
    }

    func testStrokesDidSet_markStrokeAsDeleted_removesStrokeFromDrawing() {
        var doodle = DTDoodleWrapper()
        let strokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        let strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        let strokeThree = DTAdaptedTestHelper.createStrokeWrapper()

        doodle.strokes = [strokeOne, strokeTwo, strokeThree]

        XCTAssertEqual(doodle.strokes.count, 3)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 3)
        XCTAssertEqual(doodle.strokes.map { $0.stroke }, doodle.drawing.dtStrokes)

        doodle.strokes[1].isDeleted = true

        XCTAssertEqual(doodle.strokes.count, 3)
        XCTAssertEqual(doodle.drawing.dtStrokes.count, 2)
        XCTAssertEqual(doodle.strokes.filter { !$0.isDeleted }.map { $0.stroke }, doodle.drawing.dtStrokes)
    }

    func testInit_emptyInit_isCorrect() {
        let doodle = DTDoodleWrapper()
        XCTAssert(doodle.strokes.isEmpty)
        XCTAssert(doodle.drawing.dtStrokes.isEmpty)
    }

    func testInit_withAdaptedDoodle_isCorrect() throws {
        let adaptedDoodle = try DTAdaptedTestHelper.createAdaptedDoodle()
        let doodle = DTDoodleWrapper(doodle: adaptedDoodle)
        XCTAssertEqual(doodle.createdAt, adaptedDoodle.createdAt)
        XCTAssertEqual(doodle.doodleId, adaptedDoodle.doodleId)
        XCTAssertEqual(doodle.strokes, adaptedDoodle.strokes.map { DTStrokeWrapper(stroke: $0) })
        XCTAssertEqual(doodle.drawing.dtStrokes, doodle.strokes.map { $0.stroke })
    }

}
