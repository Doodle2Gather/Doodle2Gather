import PencilKit
import DTSharedLibrary

/// A wrapper that wraps around PencilKit and supports additional logic and data
/// for the pencil kit drawings.
struct DTDoodleWrapper {

    var doodleId: UUID
    // Model
    var strokes: [DTStrokeWrapper] {
        didSet {
            drawing = PKDrawing(strokes: self.strokes.filter({ !$0.isDeleted })
                                    .compactMap { $0.stroke })
        }
    }
    // View
    var drawing: PKDrawing

    init() {
        self.doodleId = UUID()
        self.strokes = []
        self.drawing = PKDrawing()
    }

    init(doodle: DTAdaptedDoodle) {
        self.doodleId = doodle.doodleId ?? UUID()
        self.strokes = doodle.strokes.compactMap { DTStrokeWrapper(stroke: $0) }
        self.drawing = PKDrawing(strokes: self.strokes.filter({ !$0.isDeleted })
                                    .compactMap { $0.stroke })
    }

}
