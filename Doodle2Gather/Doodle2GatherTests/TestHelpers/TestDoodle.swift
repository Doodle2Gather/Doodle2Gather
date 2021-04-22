import CoreGraphics
import Doodle2Gather
import DTSharedLibrary

struct TestDoodle: DTDoodle {

    var dtStrokes: [TestStroke]
    var strokesFrame: CGRect?

    init<D>(from doodle: D) where D: DTDoodle {
        self.dtStrokes = doodle.dtStrokes.map { TestStroke(from: $0) }
    }

    // Initializes empty strokes
    init(from data: DTAdaptedDoodle) {
        self.dtStrokes = data.strokes.compactMap { TestStroke(from: $0) }
    }

    mutating func removeStrokes<S>(_: [S]) where S: DTStroke {}

    mutating func addStrokes<S>(_: [S]) where S: DTStroke {}

    mutating func removeStroke<S>(_: S) where S: DTStroke {}

    mutating func addStroke<S>(_: S) where S: DTStroke {}

}
