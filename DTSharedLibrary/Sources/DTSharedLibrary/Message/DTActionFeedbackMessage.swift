import Foundation

public struct DTActionFeedbackMessage: Codable, Comparable {
    var type = DTMessageType.actionFeedback

    public let success: Bool
    public let message: String
    public let id: UUID?
    public let createdAt: Date?
    public let orginalAction: DTAdaptedAction

    public var isActionDenied: Bool
    public var undoAction: DTAdaptedAction?
    public let actionHistories: [DTAdaptedAction]

    public init(success: Bool, message: String,
                id: UUID?, createdAt: Date?,
                action: DTAdaptedAction,
                isActionDenied: Bool = false,
                actionHistories: [DTAdaptedAction] = []
    ) {
        self.success = success
        self.message = message
        self.id = id
        self.createdAt = createdAt
        self.orginalAction = action

        self.isActionDenied = isActionDenied
        self.actionHistories = actionHistories
        if isActionDenied {
            // TODO: get partial action to be reverted
            self.undoAction = action.reverse()
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
