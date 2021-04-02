import Foundation

public struct DTActionFeedbackMessage: Codable, Comparable {
    var type = DTMessageType.actionFeedback
    public let success: Bool
    public let message: String
    public let id: UUID?
    public let roomId: UUID
    public let strokesAdded: Data
    public let strokesRemoved: Data
    public let createdAt: Date?
    
    public init(success: Bool, message: String, id: UUID?, roomId: UUID, strokesAdded: Data, strokesRemoved: Data, createdAt: Date?) {
        self.success = success
        self.message = message
        self.id = id
        self.roomId = roomId
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.createdAt = createdAt
    }

    public static func < (lhs: DTActionFeedbackMessage, rhs: DTActionFeedbackMessage) -> Bool {
        guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else {
            return false
        }
        return lhsDate < rhsDate
    }

    public static func == (lhs: DTActionFeedbackMessage, rhs: DTActionFeedbackMessage) -> Bool {
        lhs.id == rhs.id
    }
}
