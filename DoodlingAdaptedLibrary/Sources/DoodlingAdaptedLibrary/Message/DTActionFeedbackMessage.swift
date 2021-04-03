import Foundation

public struct DTActionFeedbackMessage: Codable, Comparable {
    var type = DTMessageType.actionFeedback
    public let success: Bool
    public let message: String
    public let id: UUID?
    public let createdAt: Date?
    public let orginalAction: DTAdaptedAction
    public let actionToTake: DTAdaptedAction?
    
    public init(success: Bool, message: String,
                id: UUID?, createdAt: Date?,
                action: DTAdaptedAction) {
        self.success = success
        self.message = message
        self.id = id
        self.createdAt = createdAt
        self.orginalAction = action
        if success {
            actionToTake = nil
        } else {
            actionToTake = action.reverse()
        }
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
