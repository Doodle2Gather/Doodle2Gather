import Vapor
import DTSharedLibrary

extension DTAdaptedUser {
    init(user: PersistedDTUser) {
        self.init(
            id = user.id
            displayName = user.displayName
            email = user.email
            accessibleRooms = user.accessibleRooms
            updatedAt = user.updatedAt
        )
    }
    
    func makePersistedUser() -> PersistedDTUser {
        PersistedDTUser(id: id, displayName: displayName, email: email)
    }

    func isSameUser(as persisted: PersistedDTUser) -> Bool {
        id == persisted.id && displayName == persisted.displayName && email && persisted.email
    }
}

// MARK: - Content

extension DTAdaptedUser: Content {}
