import Vapor
import DTSharedLibrary

extension DTAdaptedDoodle {
    init(doodle: PersistedDTDoodle) {
        self.init(
            roomId: doodle.$room.id,
            doodleId: try? doodle.requireID(),
            strokes: doodle.getStrokes().map { DTAdaptedStroke(stroke: $0) }
        )
    }
}

// MARK: - Content

extension DTAdaptedDoodle: Content {}
