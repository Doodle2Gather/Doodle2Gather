import Foundation

public struct DTDispatchActionMessage: Codable {
    var type = DTMessageType.dispatchAction
    public let success: Bool
    public let message: String
    public let action: DTAdaptedAction

    public init(success: Bool, message: String, action: DTAdaptedAction) {
        self.success = success
        self.message = message
        self.action = action
    }
}
