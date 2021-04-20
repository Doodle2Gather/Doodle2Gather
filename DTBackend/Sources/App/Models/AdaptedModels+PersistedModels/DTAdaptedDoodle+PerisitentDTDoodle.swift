import Vapor
import DTSharedLibrary

/// Supports the conversion between `DTAdaptedDoodle` and `PersistedDTDoodle`
extension DTAdaptedDoodle {
    init(doodle: PersistedDTDoodle) {
        self.init(
            roomId: doodle.$room.id,
            createdAt: doodle.createdAt ?? Date(),
            doodleId: try? doodle.requireID(),
            strokes: doodle.getStrokes().map { DTAdaptedStroke(stroke: $0) },
            text: doodle.getText().map { DTAdaptedText(text: $0) }
        )
    }
}

extension DTAdaptedDoodle.CreateRequest {
    func makePersistedDoodle() -> PersistedDTDoodle {
        PersistedDTDoodle(
            roomId: roomId
        )
    }
}

// MARK: - Content

extension DTAdaptedDoodle: Content {}
