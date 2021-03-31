import Foundation

public struct DTInitiateActionMessage: Codable {
    var type = DTMessageType.initiateAction
    public let strokesAdded: String
    public let strokesRemoved: String
}
