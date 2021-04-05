import Foundation

public struct DTActionFeedbackMessage: Codable {
    var type = DTMessageType.actionFeedback

    public let success: Bool
    public let message: String
    public let orginalAction: DTAdaptedAction
    public let dispatchedAction: DTAdaptedAction?

    public init(success: Bool, message: String,
                orginalAction: DTAdaptedAction, dispatchedAction: DTAdaptedAction?
    ) {
        self.success = success
        self.message = message
        self.orginalAction = orginalAction
        self.dispatchedAction = dispatchedAction
    }
}
