import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let strokesAdded: Set<Data>
    public let strokesRemoved: Set<Data>
    public let id: UUID
    public let roomId: UUID
    
    public init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>,
                id: UUID, roomId: UUID) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.id = id
        self.roomId = roomId
    }
    
    public func makeAdaptedAction() -> DTAdaptedAction {
        DTAdaptedAction(
            strokesAdded: strokesAdded,
            strokesRemoved: strokesRemoved,
            roomId: roomId,
            createdBy: id
        )
    }
}
