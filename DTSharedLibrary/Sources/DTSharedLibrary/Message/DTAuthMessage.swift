import Foundation

/// Represents the messages sent between client and server
/// in order to register a user account or to log in to his/her account
public struct DTAuthMessage: Codable {
    public let id: UUID
    public let subtype: DTAuthMessageType
}

/// Represents the message sent to the server when a user registers an account
public struct DTRegisterMessage: Codable {
    public var type = DTMessageType.auth
    public var subtype = DTAuthMessageType.register

    public let id: UUID
    public let uid: String
    public let displayName: String
    public let email: String

    public init(id: UUID, uid: String, displayName: String, email: String) {
        self.id = id
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}

/// Represents the message sent to the server then a user log in
public struct DTLoginMessage: Codable {
    public var type = DTMessageType.auth
    public var subtype = DTAuthMessageType.login

    public let id: UUID
    public let uid: String

    /// Keeping these fields for now so that the client always
    /// sends the most updated information from Firebase to the server
    public let displayName: String
    public let email: String

    public init(id: UUID, uid: String, displayName: String, email: String) {
        self.id = id
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}
