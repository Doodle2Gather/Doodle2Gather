public struct DTAdaptedUserConferenceState: Codable {
    public let id: String
    public let displayName: String
    public let isVideoOn: Bool
    public let isAudioOn: Bool

    public init(id: String, displayName: String, isVideoOn: Bool, isAudioOn: Bool) {
        self.id = id
        self.displayName = displayName
        self.isVideoOn = isVideoOn
        self.isAudioOn = isAudioOn
    }
}
