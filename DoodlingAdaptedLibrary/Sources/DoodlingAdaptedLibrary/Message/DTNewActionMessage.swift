import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let strokesAdded: Data
    public let strokesRemoved: Data
    public let roomId: UUID
}
