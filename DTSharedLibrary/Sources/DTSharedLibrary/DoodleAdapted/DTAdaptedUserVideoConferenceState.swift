public struct DTAdaptedUserVideoConferenceState: Codable {
    public let id: String
    public let displayName: String
    public let isVideoOn: Bool

    public init(id: String, displayName: String, isVideoOn: Bool) {
        self.id = id
        self.displayName = displayName
        self.isVideoOn = isVideoOn
    }
}
