import PencilKit

extension PKDrawing: DTDrawing {

    var dtStrokes: Set<PKStroke> {
        get {
            Set(strokes)
        }
        set {
            strokes = Array(newValue)
        }
    }

    init<D>(from drawing: D) where D: DTDrawing {
        self.init(strokes: drawing.dtStrokes.map({ PKStroke(from: $0) }))
    }

}
