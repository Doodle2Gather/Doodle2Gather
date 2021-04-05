import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let id: UUID
    public let action: DTAdaptedAction

    public init(actionType: DTActionType, strokes: [DTStrokeIndexPair],
                id: UUID, roomId: UUID, doodleId: UUID) {
        self.id = id
        self.action = DTAdaptedAction(
            type: actionType, strokes: strokes,
            roomId: roomId, doodleId: doodleId, createdBy: id)
    }
}
