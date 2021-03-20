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
        self.init(strokes: drawing.dtStrokes.map { PKStroke(from: $0) })
    }

    mutating func removeStrokes<S>(_ removedStrokes: Set<S>) where S: DTStroke {
        dtStrokes.subtract(removedStrokes.map { PKStroke(from: $0) })
    }

    mutating func addStrokes<S>(_ addedStrokes: Set<S>) where S: DTStroke {
        dtStrokes.formUnion(addedStrokes.map { PKStroke(from: $0) })
    }

}
