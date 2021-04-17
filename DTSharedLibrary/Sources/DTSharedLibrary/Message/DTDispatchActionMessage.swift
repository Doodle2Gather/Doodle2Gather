import Foundation

public struct DTDispatchActionMessage: Codable {
    var type = DTMessageType.dispatchAction
    public let id: UUID
    public let success: Bool
    public let message: String
    public let action: DTAdaptedAction

    public init(id: UUID, success: Bool, message: String, action: DTAdaptedAction) {
        self.id = id
        self.success = success
        self.message = message
        self.action = action
    }
}
