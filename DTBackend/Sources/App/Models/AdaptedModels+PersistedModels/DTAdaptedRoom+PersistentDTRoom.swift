import Vapor
import DTSharedLibrary

/// Supports the conversion between `DTAdaptedRoom` and `PersistedDTRoom`
extension DTAdaptedRoom {
    init(room: PersistedDTRoom) {
        self.init(
            ownerId: room.$createdBy.id,
            name: room.name,
            inviteCode: room.inviteCode,
            roomId: try? room.requireID(),
            doodles: room.getChildren().map { DTAdaptedDoodle(doodle: $0) }
        )
    }
}

extension DTAdaptedRoom.CreateRequest {
    func makePersistedRoom() -> PersistedDTRoom {
        PersistedDTRoom(
            name: name,
            createdBy: ownerId
        )
    }
}

// MARK: - Content

extension DTAdaptedRoom: Content {}
