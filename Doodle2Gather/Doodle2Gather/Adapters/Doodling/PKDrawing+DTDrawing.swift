import PencilKit
import DoodlingLibrary

extension PKDrawing: DTDoodle {

    public var dtStrokes: [PKStroke] {
        get {
            strokes
        }
        set {
            strokes = newValue
        }
    }

    public init<D>(from doodle: D) where D: DTDoodle {
        self.init(strokes: doodle.dtStrokes.map { PKStroke(from: $0) })
    }

    public mutating func removeStrokes<S>(_ removedStrokes: [S]) where S: DTStroke {
        let removed = Set(removedStrokes.map { PKStroke(from: $0) })
        dtStrokes = dtStrokes.filter { !removed.contains($0) }
    }

    public mutating func addStrokes<S>(_ addedStrokes: [S]) where S: DTStroke {
        dtStrokes.append(contentsOf: (addedStrokes.map { PKStroke(from: $0) }))
    }

}
