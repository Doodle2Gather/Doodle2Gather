import Foundation

public struct DTAdaptedAction: Codable {

    public let strokesAdded: Set<Data>
    public let strokesRemoved: Set<Data>
    public let roomId: UUID
    public let createdBy: UUID

    public init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>, roomId: UUID, createdBy: UUID) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.roomId = roomId
        self.createdBy = createdBy
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
