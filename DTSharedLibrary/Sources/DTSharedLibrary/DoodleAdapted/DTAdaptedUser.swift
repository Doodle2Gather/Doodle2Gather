import Foundation

public struct DTAdaptedUser: Codable {

    public let id: String
    public let displayName: String
    public let email: String
    public let accessibleRooms: [DTAdaptedRoom]
    public let updatedAt: Date

    public init(id: String, displayName: String, email: String, accessibleRooms: [DTAdaptedRoom], updatedAt: Date) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.accessibleRooms = accessibleRooms
        self.updatedAt = updatedAt
    }
}

extension DTAdaptedUser {
    public struct CreateRequest: Codable {
        public let id: String
        public let displayName: String
        public let email: String

        public init(id: String, displayName: String, email: String) {
            self.id = id
            self.displayName = displayName
            self.email = email
        }
    }
}

// MARK: - Hashable

extension DTAdaptedUser: Hashable {}
