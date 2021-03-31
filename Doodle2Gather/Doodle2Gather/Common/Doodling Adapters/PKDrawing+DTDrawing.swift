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

    public mutating func removeStrokes<S>(_ removedStrokes: Set<S>) where S: DTStroke {
        dtStrokes = dtStrokes.filter({ stroke in
            guard let stroke = stroke as? S else {
                fatalError("Failed to convert PKStroke to DTStroke")
            }
            return !removedStrokes.contains(stroke)
        })
    }

    public mutating func addStrokes<S>(_ addedStrokes: Set<S>) where S: DTStroke {
        dtStrokes.append(contentsOf: (addedStrokes.map { PKStroke(from: $0) }))
    }

}
