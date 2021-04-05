import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let id: UUID
    public let action: DTAdaptedAction

    public init(type: DTActionType, strokes: [Data],
                id: UUID, roomId: UUID) {
        self.action = DTAdaptedAction(
            type: type,
            strokes: strokes,
            roomId: roomId,
            createdBy: id
        )
        self.id = id
    }
}
