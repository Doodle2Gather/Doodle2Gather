import Vapor
import DTSharedLibrary

extension DTAdaptedUser {
    init(user: PersistedDTUser) {
        guard let id = user.id,
              let updatedAt = user.updatedAt else {
            fatalError("Unable to unwrap user details")
        }
        self.init(
            id: id,
            displayName: user.displayName,
            email: user.email,
            accessibleRooms: user.accessibleRooms.map { DTAdaptedRoom(room: $0) },
            updatedAt: updatedAt
        )
    }

    func isSameUser(as persisted: PersistedDTUser) -> Bool {
        id == persisted.id && displayName == persisted.displayName && email == persisted.email
    }
}

extension DTAdaptedUser.CreateRequest {
    func makePersistedUser() -> PersistedDTUser {
        PersistedDTUser(id: id, displayName: displayName, email: email)
    }
}

// MARK: - Content

extension DTAdaptedUser: Content {}

// MARK: PersistedDTUser -> DTAdaptedUser

extension PersistedDTUser {
    func toDTAdaptedUser(withRooms: Bool = true) -> DTAdaptedUser {
        if withRooms {
            return DTAdaptedUser(user: self)
        }
        guard let id = id else {
            fatalError("Unable to fetch uid from DB")
        }
        return DTAdaptedUser(id: id, displayName: displayName, email: email)
    }
}
