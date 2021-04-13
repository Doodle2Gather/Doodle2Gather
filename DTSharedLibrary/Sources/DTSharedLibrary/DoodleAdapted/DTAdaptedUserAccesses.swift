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

//extension DTAdaptedUserAccesses {
//    public struct CreateRequest: Codable {
//        public let id: String
//        public let displayName: String
//        public let email: String
//
//        public init(id: String, displayName: String, email: String) {
//            self.id = id
//            self.displayName = displayName
//            self.email = email
//        }
//    }
//}
