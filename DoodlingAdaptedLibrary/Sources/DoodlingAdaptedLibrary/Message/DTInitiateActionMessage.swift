import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let id: UUID
    public let action: DTAdaptedAction
    
    public init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>,
                id: UUID, roomId: UUID) {
        self.action = DTAdaptedAction(
            strokesAdded: strokesAdded,
            strokesRemoved: strokesRemoved,
            roomId: roomId,
            createdBy: id
        )
        self.id = id
    }
}
