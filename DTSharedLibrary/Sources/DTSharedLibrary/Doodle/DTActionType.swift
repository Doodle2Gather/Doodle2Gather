/// Represents four types of action that can be sent between the client
/// and the server to update a doodle
public enum DTActionType: String, Codable {
    case add, remove, unremove, modify

    case unknown // handle failed conversion from PersistedDTAction to DTAdaptedAction
}
