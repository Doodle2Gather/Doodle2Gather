import Foundation

public struct DTActionFeedbackMessage: Codable {
    var type = DTRoomMessageType.actionFeedback

    public let id: UUID
    public let success: Bool
    public let message: String
    public let orginalAction: DTAdaptedAction
    public let dispatchedAction: DTAdaptedAction?

    public init(id: UUID, success: Bool, message: String,
                orginalAction: DTAdaptedAction, dispatchedAction: DTAdaptedAction?
    ) {
        self.id = id
        self.success = success
        self.message = message
        self.orginalAction = orginalAction
        self.dispatchedAction = dispatchedAction
    }
}
