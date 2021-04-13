import Foundation

public struct DTAdaptedUserAccesses: Codable {

    public let id: UUID
    public let user: DTAdaptedUser
    public let room: DTAdaptedRoom

    public init(id: UUID, user: DTAdaptedUser, room: DTAdaptedRoom) {
        self.id = id
        self.user = user
        self.room = room
    }
}
