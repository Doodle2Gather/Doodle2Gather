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

    func isSameDoodle(as persisted: PersistedDTDoodle) -> Bool {
        guard let persistedId = try? persisted.requireID() else {
            return false
        }
        return persistedId == doodleId
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
