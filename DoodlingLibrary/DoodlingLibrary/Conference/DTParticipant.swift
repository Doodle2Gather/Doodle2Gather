public protocol DTParticipant {
    var userId: UUID { get }
    var displayName: String { get set }
    var isVideoOn: Bool { get set }
    var isAudioOn: Bool { get set }
}
