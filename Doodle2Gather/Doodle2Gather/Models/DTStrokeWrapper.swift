import PencilKit
import DTSharedLibrary

/// A wrapper for strokes that wraps around PencilKit and supports additional
/// logic and data for the pencil kit strokes.
///
/// The PencilKit model can be replaced by any stroke model that adopts
/// the `DTStroke` protocol.
struct DTStrokeWrapper {

    /// The ID that identifies this stroke for differentiation purposes + change tracking.
    var strokeId: UUID

    /// The ID string of the user that created this stroke.
    var createdBy: String

    /// Whether this stroke has been deleted by some user. Soft deletion is performed.
    var isDeleted: Bool

    // Nested model
    var stroke: PKStroke

    init(stroke: PKStroke, createdBy: String) {
        strokeId = UUID()
        self.createdBy = createdBy
        isDeleted = false
        self.stroke = stroke
    }

    init(stroke: PKStroke, strokeId: UUID, createdBy: String, isDeleted: Bool = false) {
        self.strokeId = strokeId
        self.createdBy = createdBy
        self.isDeleted = isDeleted
        self.stroke = stroke
    }

    init?(stroke: DTAdaptedStroke) {
        self.strokeId = stroke.strokeId
        self.createdBy = stroke.createdBy
        self.isDeleted = stroke.isDeleted
        guard let stroke = PKStroke(from: stroke) else {
            return nil
        }
        self.stroke = stroke
    }

    init?(data: Data, strokeId: UUID, createdBy: String, isDeleted: Bool) {
        let decoder = JSONDecoder()
        guard let stroke = try? decoder.decode(PKStroke.self, from: data) else {
            return nil
        }
        self.stroke = stroke
        self.strokeId = strokeId
        self.createdBy = createdBy
        self.isDeleted = isDeleted
    }

}
