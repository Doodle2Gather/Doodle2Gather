import Foundation

public struct DispatchActionMessage: Codable, Comparable {
    var type = DTMessageType.dispatchAction
    let success: Bool
    let message: String
    let id: UUID?
    let strokesAdded: String
    let strokesRemoved: String
    let createdAt: Date?
    
    public init(success: Bool, message: String, id: UUID?, strokesAdded: String, strokesRemoved: String, createdAt: Date?) {
        self.success = success
        self.message = message
        self.id = id
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.createdAt = createdAt
    }

    public static func < (lhs: DispatchActionMessage, rhs: DispatchActionMessage) -> Bool {
        guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else {
            return false
        }
        return lhsDate < rhsDate
    }

    public static func == (lhs: DispatchActionMessage, rhs: DispatchActionMessage) -> Bool {
        lhs.id == rhs.id
    }
}
