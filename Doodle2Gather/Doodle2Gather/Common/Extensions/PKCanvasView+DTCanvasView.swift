import PencilKit

extension PKCanvasView: DTCanvasView {

    func registerDelegate(_ delegate: DTCanvasViewDelegate) {
        let wrapperDelegate = WrapperPKCanvasViewDelegate(delegate: delegate)
        self.delegate = wrapperDelegate
    }

    func loadDrawing<D>(_: D) where D: DTDrawing {
        self.drawing = PKDrawing(from: drawing)
        self.alwaysBounceVertical = true
    }

}

class WrapperPKCanvasViewDelegate: NSObject, PKCanvasViewDelegate {

    private weak var delegate: DTCanvasViewDelegate?

    init(delegate: DTCanvasViewDelegate) {
        self.delegate = delegate
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        delegate?.canvasViewDrawingDidChange(canvasView)
    }

}
