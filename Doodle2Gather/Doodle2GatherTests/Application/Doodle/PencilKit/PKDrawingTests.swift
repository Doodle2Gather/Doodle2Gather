import XCTest
import PencilKit
@testable import Doodle2Gather

class PKDrawingTests: XCTestCase {

    private let decoder = JSONDecoder()

    func testDtStroke_get_isCorrect() {
        let drawing = PencilKitTestHelper.createDrawing()
        XCTAssertEqual(drawing.dtStrokes, drawing.strokes)
    }

    func testDtStroke_set_updatesStrokes() {
        var drawingOne = PencilKitTestHelper.createDrawing()
        let drawingTwo = PencilKitTestHelper.createDrawing()

        drawingOne.dtStrokes = drawingTwo.dtStrokes
        XCTAssertEqual(drawingOne.dtStrokes, drawingTwo.dtStrokes)
        XCTAssertEqual(drawingOne.strokes, drawingTwo.strokes)
    }

    func testDtStroke_append_updatesStrokes() {
        var drawing = PencilKitTestHelper.createDrawing()

        var strokes = drawing.dtStrokes
        let stroke = PencilKitTestHelper.createStroke()

        drawing.dtStrokes.append(stroke)

        strokes.append(stroke)

        XCTAssertEqual(drawing.dtStrokes, strokes)
        XCTAssertEqual(drawing.strokes, strokes)
    }

    func testDtStroke_remove_updatesStrokes() {
        var drawing = PencilKitTestHelper.createDrawing()

        var strokes = drawing.dtStrokes
        strokes.remove(at: 4)
        drawing.dtStrokes.remove(at: 4)

        XCTAssertEqual(drawing.dtStrokes, strokes)
        XCTAssertEqual(drawing.strokes, strokes)
    }

    func testInit_adaptedDoodle_isCorrect() throws {
        let adaptedDoodle = try DTAdaptedTestHelper.createAdaptedDoodle()

        let drawing = PKDrawing(from: adaptedDoodle)

        XCTAssertEqual(drawing.dtStrokes,
                       try adaptedDoodle.strokes.map { try decoder.decode(PKStroke.self, from: $0.stroke) })
    }

    func testInit_anotherDtDoodle_isCorrect() throws {
        let anotherDoodle = DTAdaptedTestHelper.createTestDoodle()

        let drawing = PKDrawing(from: anotherDoodle)

        XCTAssertEqual(drawing.dtStrokes.map { $0.color }, anotherDoodle.dtStrokes.map { $0.color })
        XCTAssertEqual(drawing.dtStrokes.map { $0.mask }, anotherDoodle.dtStrokes.map { $0.mask })
        XCTAssertEqual(drawing.dtStrokes.map { $0.tool }, anotherDoodle.dtStrokes.map { $0.tool })
        XCTAssertEqual(drawing.dtStrokes.map { $0.transform }, anotherDoodle.dtStrokes.map { $0.transform })
    }

    func testEquatableHashable_sameDrawing_isEqual() {
        let drawingOne = PencilKitTestHelper.createDrawing()
        let drawingTwo = PKDrawing(strokes: drawingOne.dtStrokes)

        XCTAssertEqual(drawingOne.dtStrokes, drawingTwo.dtStrokes)
        XCTAssertEqual(drawingOne.hashValue, drawingTwo.hashValue)
    }

    func testRemoveStrokes_singleStroke_isRemoved() {
        var drawing = PencilKitTestHelper.createDrawing()
        guard let stroke = drawing.strokes.randomElement() else {
            XCTFail("Should contain stroke")
            return
        }
        XCTAssert(drawing.dtStrokes.contains(stroke))
        drawing.removeStrokes([stroke])
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))
    }

    func testRemoveStrokes_multipleStrokes_areRemoved() {
        var drawing = PencilKitTestHelper.createDrawing()
        let strokes = [drawing.dtStrokes[2], drawing.dtStrokes[6]]
        XCTAssert(drawing.dtStrokes.contains(strokes[0]))
        XCTAssert(drawing.dtStrokes.contains(strokes[1]))

        drawing.removeStrokes(strokes)
        XCTAssertFalse(drawing.dtStrokes.contains(strokes[0]))
        XCTAssertFalse(drawing.dtStrokes.contains(strokes[1]))
    }

    func testRemoveStrokes_strokeNotInDrawing_noChange() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 5)
        let stroke = PencilKitTestHelper.createStroke()

        XCTAssertEqual(drawing.dtStrokes.count, 5)
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))

        drawing.removeStrokes([stroke])
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))
        XCTAssertEqual(drawing.dtStrokes.count, 5)
    }

    func testRemoveStrokes_emptyArray_noChange() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 5)

        XCTAssertEqual(drawing.dtStrokes.count, 5)
        drawing.removeStrokes([PKStroke]())
        XCTAssertEqual(drawing.dtStrokes.count, 5)
    }

    func testRemoveStroke_strokeInDrawing_isRemoved() {
        var drawing = PencilKitTestHelper.createDrawing()
        guard let stroke = drawing.strokes.randomElement() else {
            XCTFail("Should contain stroke")
            return
        }
        XCTAssert(drawing.dtStrokes.contains(stroke))
        drawing.removeStroke(stroke)
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))
    }

    func testRemoveStroke_strokeNotInDrawing_noChange() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 5)
        let stroke = PencilKitTestHelper.createStroke()

        XCTAssertEqual(drawing.dtStrokes.count, 5)
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))

        drawing.removeStroke(stroke)
        XCTAssertFalse(drawing.dtStrokes.contains(stroke))
        XCTAssertEqual(drawing.dtStrokes.count, 5)
    }

    func testAddStrokes_singleStroke_isAppended() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 10)
        let stroke = PencilKitTestHelper.createStroke()
        XCTAssertEqual(drawing.dtStrokes.count, 10)

        drawing.addStrokes([stroke])
        XCTAssertEqual(drawing.dtStrokes.count, 11)
        XCTAssertEqual(drawing.dtStrokes.last, stroke)
    }

    func testAddStrokes_multipleStrokes_areAppended() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 10)
        let strokeOne = PencilKitTestHelper.createStroke()
        let strokeTwo = PencilKitTestHelper.createStroke()
        XCTAssertEqual(drawing.dtStrokes.count, 10)

        drawing.addStrokes([strokeOne, strokeTwo])
        XCTAssertEqual(drawing.dtStrokes.count, 12)
        XCTAssertEqual(drawing.dtStrokes[10], strokeOne)
        XCTAssertEqual(drawing.dtStrokes[11], strokeTwo)
    }

    func testAddStrokes_emptyArray_noChange() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 10)
        XCTAssertEqual(drawing.dtStrokes.count, 10)

        drawing.addStrokes([PKStroke]())
        XCTAssertEqual(drawing.dtStrokes.count, 10)
    }

    func testAddStroke_singleStroke_isAppended() {
        var drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 10)
        let stroke = PencilKitTestHelper.createStroke()
        XCTAssertEqual(drawing.dtStrokes.count, 10)

        drawing.addStroke(stroke)
        XCTAssertEqual(drawing.dtStrokes.count, 11)
        XCTAssertEqual(drawing.dtStrokes[10], stroke)
    }

    func testStrokesFrame_withStrokes_containsAllRenderedStrokes() {
        let drawing = PencilKitTestHelper.createDrawing()
        guard let strokesFrame = drawing.strokesFrame else {
            XCTFail("Should not return nil for strokesFrame")
            return
        }

        for stroke in drawing.dtStrokes {
            let renderBounds = stroke.renderBounds
            XCTAssert(renderBounds.minX >= strokesFrame.minX)
            XCTAssert(renderBounds.maxX <= strokesFrame.maxX)
            XCTAssert(renderBounds.minY >= strokesFrame.minY)
            XCTAssert(renderBounds.maxY <= strokesFrame.maxY)
        }
    }

    func testStrokesFrame_noStrokes_isNil() {
        let drawing = PencilKitTestHelper.createDrawing(numberOfStrokes: 0)
        XCTAssertNil(drawing.strokesFrame)
    }

}
