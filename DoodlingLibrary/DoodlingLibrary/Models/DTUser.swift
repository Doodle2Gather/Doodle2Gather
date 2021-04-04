public struct DTUser {
    public let uid: String
    public let displayName: String
    public let email: String

    public init(uid: String, displayName: String, email: String) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}
