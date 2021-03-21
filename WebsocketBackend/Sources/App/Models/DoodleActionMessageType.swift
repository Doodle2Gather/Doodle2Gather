import Foundation

enum DoodleActionMessageType: String, Codable {
    // Client to server types
    case newAction
    // Server to client types
    case handshake, feedback
}

struct DoodleActionMessageData: Codable {
    let type: DoodleActionMessageType
    let id: UUID
}

struct DoodleActionHandShake: Codable {
    var type = DoodleActionMessageType.handshake
    let id: UUID
}

struct NewDoodleActionMessage: Codable {
    let strokesAdded: String
    let strokesRemoved: String
}

struct NewDoodleActionFeedback: Codable, Comparable {
    var type = DoodleActionMessageType.feedback
    let success: Bool
    let message: String
    let id: UUID?
    let strokesAdded: String
    let strokesRemoved: String
    let createdAt: Date?

    static func < (lhs: NewDoodleActionFeedback, rhs: NewDoodleActionFeedback) -> Bool {
        guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else {
            return false
        }
        return lhsDate < rhsDate
    }

    static func == (lhs: NewDoodleActionFeedback, rhs: NewDoodleActionFeedback) -> Bool {
        lhs.id == rhs.id
    }
}
