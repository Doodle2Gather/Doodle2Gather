import PencilKit

extension PKDrawing: DTDoodle {

    var dtStrokes: Set<PKStroke> {
        get {
            Set(strokes)
        }
        set {
            strokes = Array(newValue)
        }
    }

    init<D>(from doodle: D) where D: DTDoodle {
        self.init(strokes: doodle.dtStrokes.map { PKStroke(from: $0) })
    }

    mutating func removeStrokes<S>(_ removedStrokes: Set<S>) where S: DTStroke {
        dtStrokes = dtStrokes.subtracting(removedStrokes.map { PKStroke(from: $0) })
    }

    mutating func addStrokes<S>(_ addedStrokes: Set<S>) where S: DTStroke {
        dtStrokes = dtStrokes.union(addedStrokes.map { PKStroke(from: $0) })
    }

}
