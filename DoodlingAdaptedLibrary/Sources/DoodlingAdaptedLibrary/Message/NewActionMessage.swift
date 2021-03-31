import Foundation

public struct NewActionMessage: Codable {
    var type = DTMessageType.newAction
    public let strokesAdded: String
    public let strokesRemoved: String
}
