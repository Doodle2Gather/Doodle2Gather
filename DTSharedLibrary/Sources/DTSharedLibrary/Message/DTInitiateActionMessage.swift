import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let id: UUID
    public let roomId: UUID
    public let actionType: DTActionType
    public let strokes: [DTStrokeIndexPair]

    public init(actionType: DTActionType, strokes: [DTStrokeIndexPair],
                id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
        self.actionType = actionType
        self.strokes = strokes
    }
}
