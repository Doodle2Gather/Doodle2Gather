import XCTest
import PencilKit
@testable import Doodle2Gather
@testable import DTSharedLibrary

/// Performs white-box testing for `DTCanvasGestureManager`.
class DTCanvasGestureManagerTests: XCTestCase {

    private var canvas = PKCanvasViewSpy()
    private var manager = DTCanvasGestureManager()
    private var delegateSpy = CanvasGestureManagerDelegateSpy()

    override func setUp() {
        super.setUp()
        canvas = PKCanvasViewSpy()
        manager = DTCanvasGestureManager(canvas: canvas)
        delegateSpy = CanvasGestureManagerDelegateSpy()
        manager.delegate = delegateSpy
    }

    func testInitialize_isCorrect() {
        XCTAssertFalse(canvas.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(canvas.minimumZoomScale, UIConstants.minZoom)
        XCTAssertEqual(canvas.maximumZoomScale, UIConstants.maxZoom)
        XCTAssertEqual(canvas.zoomScale, UIConstants.currentZoom)
        XCTAssertFalse(canvas.showsVerticalScrollIndicator)
        XCTAssertFalse(canvas.showsHorizontalScrollIndicator)
        XCTAssertEqual(canvas.drawingPolicy, .anyInput)
        XCTAssertEqual(canvas.contentSize, CGSize(width: 1_000_000, height: 1_000_000))
    }

    func testDelegate_canvasChange_notifiesDelegate() {
        let drawing = PKDrawing()
        canvas.drawing = drawing
        XCTAssertNotNil(delegateSpy.changedType)
        XCTAssertEqual(delegateSpy.changedDoodle, drawing)
    }

    func testDelegate_zoomChange_notifiesDelegate() {
        canvas.zoomScale = 1.05
        XCTAssertEqual(delegateSpy.changedZoom, 1.05)
    }

    func testDelegate_toolDidUse_notifiesDelegate() {
        manager.canvasViewDidBeginUsingTool(canvas)
        XCTAssert(delegateSpy.isEditing)
    }

    func testDelegate_toolDidEndUse_notifiesDelegate() {
        delegateSpy.isEditing = true
        manager.canvasViewDidEndUsingTool(canvas)
        XCTAssertFalse(delegateSpy.isEditing)
    }

    func testGestures_setMainDrawingTool_updatesGesutres() {
        manager.setMainTool(.drawing)
        XCTAssert(canvas.didAddGesture)
        XCTAssert(canvas.didRemoveGesture)
        XCTAssert(canvas.tool is PKInkingTool)
        XCTAssert(canvas.drawingGestureRecognizer.isEnabled)
    }

    func testGestures_setMainEraserTool_updatesGesutres() {
        manager.setMainTool(.eraser)
        XCTAssert(canvas.didAddGesture)
        XCTAssert(canvas.didRemoveGesture)
        XCTAssert(canvas.tool is PKEraserTool)
        XCTAssert(canvas.drawingGestureRecognizer.isEnabled)
    }

    func testGestures_setMainCursorTool_updatesGesutres() {
        manager.setMainTool(.cursor)
        XCTAssert(canvas.didAddGesture)
        XCTAssert(canvas.didRemoveGesture)
        XCTAssertFalse(canvas.drawingGestureRecognizer.isEnabled)
    }

    func testGestures_setMainShapesTool_updatesGesutres() {
        manager.setMainTool(.shapes)
        XCTAssert(canvas.didAddGesture)
        XCTAssert(canvas.didRemoveGesture)
        XCTAssertFalse(canvas.drawingGestureRecognizer.isEnabled)
    }

}

extension DTCanvasGestureManagerTests {

    class PKCanvasViewSpy: PKCanvasView {

        var didAddGesture = false
        var didRemoveGesture = false

        override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
            super.addGestureRecognizer(gestureRecognizer)
            didAddGesture = true
        }

        override func removeGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
            super.removeGestureRecognizer(gestureRecognizer)
            didRemoveGesture = true
        }

    }

    class CanvasGestureManagerDelegateSpy: CanvasGestureManagerDelegate {
        var changedZoom: CGFloat?
        var changedType: DTActionType?
        var changedDoodle: PKDrawing?
        var isEditing = false
        var didSelect = false
        var selectedColor: UIColor?

        func canvasZoomScaleDidChange(scale: CGFloat) {
            changedZoom = scale
        }

        func canvasViewDidChange(type: DTActionType, newDoodle: PKDrawing) {
            changedType = type
            changedDoodle = newDoodle
        }

        func setCanvasIsEditing(_ isEditing: Bool) {
            self.isEditing = isEditing
        }

        func strokeDidSelect(color: UIColor) {
            didSelect = true
            selectedColor = color
        }

        func strokeDidUnselect() {
            didSelect = false
            selectedColor = nil
        }

    }

}
