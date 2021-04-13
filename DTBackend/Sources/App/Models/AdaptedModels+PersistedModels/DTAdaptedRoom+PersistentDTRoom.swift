import Vapor
import DTSharedLibrary

extension DTAdaptedRoom {
    init(room: PersistedDTRoom) {
        self.init(
            ownerId: room.$createdBy.id,
            roomId: try? room.requireID(),
            name: room.name,
            inviteCode: room.inviteCode,
            doodles: room.doodles.map { DTAdaptedDoodle(doodle: $0) }
        )
    }
}

// MARK: - Content

extension DTAdaptedRoom: Content {}
