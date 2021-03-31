import Foundation

public struct DTActionFeedbackMessage: Codable, Comparable {
    var type = DTMessageType.actionFeedback
    let success: Bool
    let message: String
    let id: UUID?
    let roomId: UUID
    let strokesAdded: Data
    let strokesRemoved: Data
    let createdAt: Date?
    
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
