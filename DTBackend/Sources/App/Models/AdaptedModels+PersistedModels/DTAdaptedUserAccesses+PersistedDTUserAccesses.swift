import Vapor
import DTSharedLibrary

extension DTAdaptedUserAccesses {
    init(userAccesses: PersistedDTUserAccesses) {
        guard let id = userAccesses.id else {
            fatalError("Unable to unwrap user details")
        }
        self.init(
            id: id,
            user: DTAdaptedUser(user: userAccesses.user),
            room: DTAdaptedRoom(room: userAccesses.room)
        )
    }
}
// MARK: - Content

extension DTAdaptedUserAccesses: Content { }
