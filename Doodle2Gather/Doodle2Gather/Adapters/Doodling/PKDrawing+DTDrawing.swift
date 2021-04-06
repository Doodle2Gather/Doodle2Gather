import PencilKit
import DTFrontendLibrary
import DTSharedLibrary

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

    public init(from doodle: DTAdaptedDoodle) {
        self.init(strokes: doodle.strokes.compactMap { PKStroke(from: $0) })
    }

    public mutating func removeStrokes<S>(_ removedStrokes: [S]) where S: DTStroke {
        let removed = Set(removedStrokes)
        dtStrokes = dtStrokes.filter({ stroke in
            guard let stroke = stroke as? S else {
                fatalError("Failed to convert PKStroke to DTStroke")
            }
            return !removed.contains(stroke)
        })
    }

    public mutating func addStrokes<S>(_ addedStrokes: [S]) where S: DTStroke {
        dtStrokes.append(contentsOf: (addedStrokes.map { PKStroke(from: $0) }))
    }

}
