import Vapor
import DTSharedLibrary

extension DTAdaptedUserAccesses {
    init(userAccesses: PersistedDTUserAccesses) {
        guard let userId = userAccesses.user.id else {
            fatalError("Unable to fetch user ID from userAccesses")
        }
        self.init(userId: userId,
                  displayName: userAccesses.user.displayName,
                  isOwner: userAccesses.isOwner,
                  canEdit: userAccesses.canEdit,
                  canVideoConference: userAccesses.canVideoConference,
                  canChat: userAccesses.canChat)
    }
}
// MARK: - Content

extension DTAdaptedUserAccesses: Content { }
