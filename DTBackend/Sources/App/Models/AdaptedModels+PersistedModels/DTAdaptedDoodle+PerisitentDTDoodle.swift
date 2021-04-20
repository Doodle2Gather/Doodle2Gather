import Vapor
import DTSharedLibrary

extension DTAdaptedDoodle {
    init(doodle: PersistedDTDoodle) {
        self.init(
            roomId: doodle.$room.id,
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
