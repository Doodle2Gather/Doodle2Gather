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

}
