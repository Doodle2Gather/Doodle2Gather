import PencilKit

extension PKCanvasView: DTCanvasView {

    func registerDelegate(_ delegate: DTCanvasViewDelegate) -> DTCanvasViewDelegate {
        let wrapperDelegate = WrapperPKCanvasViewDelegate(delegate: delegate)
        self.delegate = wrapperDelegate
        return wrapperDelegate
    }

    func loadDrawing<D>(_: D) where D: DTDrawing {
        self.drawing = PKDrawing(from: drawing)
        self.alwaysBounceVertical = true
        // TODO: Remove this line once a DT version of drawing policy is added.
        self.drawingPolicy = .anyInput
    }

    func getStrokes<S>() -> Set<S>? where S: DTStroke {
        drawing.dtStrokes as? Set<S>
    }

    func getDrawing<D>() -> D? where D: DTDrawing {
        drawing as? D
    }

}

class WrapperPKCanvasViewDelegate: NSObject, PKCanvasViewDelegate, DTCanvasViewDelegate {

    private weak var actualDelegate: DTCanvasViewDelegate?

    init(delegate: DTCanvasViewDelegate) {
        self.actualDelegate = delegate
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        actualDelegate?.canvasViewDrawingDidChange(canvasView)
    }

    func canvasViewDrawingDidChange(_ canvasView: DTCanvasView) {
        actualDelegate?.canvasViewDrawingDidChange(canvasView)
    }

}
