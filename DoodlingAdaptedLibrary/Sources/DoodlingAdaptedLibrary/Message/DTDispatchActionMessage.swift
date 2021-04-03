import Foundation

public struct DTDispatchActionMessage: Codable, Comparable {
    var type = DTMessageType.dispatchAction
    public let success: Bool
    public let message: String
    public let id: UUID?
    public let createdAt: Date?
    public let action: DTAdaptedAction
    
    public init(success: Bool, message: String, id: UUID?, createdAt: Date?,
                action: DTAdaptedAction) {
        self.success = success
        self.message = message
        self.id = id
        self.createdAt = createdAt
        self.action = action
    }

    public static func < (lhs: DTDispatchActionMessage, rhs: DTDispatchActionMessage) -> Bool {
        guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else {
            return false
        }
        return lhsDate < rhsDate
    }

    public static func == (lhs: DTDispatchActionMessage, rhs: DTDispatchActionMessage) -> Bool {
        lhs.id == rhs.id
    }
}
