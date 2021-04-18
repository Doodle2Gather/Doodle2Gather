import PencilKit
import DTSharedLibrary

struct DTStrokeWrapper {

    var strokeId: UUID
    var createdBy: String
    var isDeleted: Bool

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
        self.createdBy = stroke.createdBy.uuidString
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
