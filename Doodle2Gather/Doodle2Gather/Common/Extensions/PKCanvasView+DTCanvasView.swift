import PencilKit

extension PKCanvasView: DTCanvasView {

    func registerDelegate(_ delegate: DTCanvasViewDelegate) -> DTCanvasViewDelegate {
        let wrapperDelegate = WrapperPKCanvasViewDelegate(delegate: delegate)
        self.delegate = wrapperDelegate
        return wrapperDelegate
    }

    func loadDoodle<D>(_ doodle: D) where D: DTDoodle {
        self.drawing = PKDrawing(from: doodle)
        self.alwaysBounceVertical = true
        // TODO: Remove this line once a DT version of drawing policy is added.
        self.drawingPolicy = .anyInput
    }

    func getStrokes<S>() -> Set<S>? where S: DTStroke {
        drawing.dtStrokes as? Set<S>
    }

    func getDoodle<D>() -> D? where D: DTDoodle {
        drawing as? D
    }

}

class WrapperPKCanvasViewDelegate: NSObject, PKCanvasViewDelegate, DTCanvasViewDelegate {

    private weak var actualDelegate: DTCanvasViewDelegate?

    init(delegate: DTCanvasViewDelegate) {
        self.actualDelegate = delegate
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        actualDelegate?.canvasViewDoodleDidChange(canvasView)
    }

    func canvasViewDoodleDidChange(_ canvasView: DTCanvasView) {
        actualDelegate?.canvasViewDoodleDidChange(canvasView)
    }

}
