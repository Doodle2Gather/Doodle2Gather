import PencilKit
import DTSharedLibrary

/// A wrapper for doodles that wraps around PencilKit and supports additional
/// logic and data for the pencil kit drawings.
///
/// The PencilKit model can be replaced by any doodle model that adopts
/// the `DTDoodle` protocol.
struct DTDoodleWrapper {

    /// The ID that identifies this doodle for differentiation purposes.
    var doodleId: UUID

    /// The date at which this doodle was created.
    var createdAt: Date

    // Nested models
    var strokes: [DTStrokeWrapper] {
        didSet {
            drawing = PKDrawing(strokes: self.strokes.filter({ !$0.isDeleted })
                                    .compactMap { $0.stroke })
        }
    }
    var drawing: PKDrawing

    init() {
        self.doodleId = UUID()
        self.strokes = []
        self.drawing = PKDrawing()
        self.createdAt = Date()
        assert(checkRep())
    }

    init(doodle: DTAdaptedDoodle) {
        self.doodleId = doodle.doodleId ?? UUID()
        self.strokes = doodle.strokes.compactMap { DTStrokeWrapper(stroke: $0) }
        self.drawing = PKDrawing(strokes: self.strokes.filter({ !$0.isDeleted })
                                    .compactMap { $0.stroke })
        self.createdAt = doodle.createdAt
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        var drawingCounter = 0
        for stroke in strokes {
            if stroke.isDeleted {
                continue
            }
            if drawingCounter >= drawing.dtStrokes.count
                || stroke.stroke != drawing.dtStrokes[drawingCounter] {
                return false
            }
            drawingCounter += 1
        }
        return drawingCounter == drawing.dtStrokes.count
    }

}
