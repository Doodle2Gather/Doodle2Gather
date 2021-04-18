import Vapor
import DTSharedLibrary

extension DTAdaptedUserAccesses {
    init(userAccesses: PersistedDTUserAccesses) {
        guard let roomId = userAccesses.room.id else {
            fatalError("Unable to unwrap room ID")
        }
        self.init(user: DTAdaptedUser(user: userAccesses.user),
                  roomId: roomId,
                  isOwner: userAccesses.isOwner,
                  canEdit: userAccesses.canEdit,
                  canVideoConference: userAccesses.canVideoConference,
                  canChat: userAccesses.canChat)
    }
}
// MARK: - Content

extension DTAdaptedUserAccesses: Content { }
