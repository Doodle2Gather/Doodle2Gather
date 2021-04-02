import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let strokesAdded: Data
    public let strokesRemoved: Data
    public let id: UUID?
    public let roomId: UUID
    
    public init(strokesAdded: Data, strokesRemoved: Data, id: UUID?, roomId: UUID) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.id = id
        self.roomId = roomId
    }
}
