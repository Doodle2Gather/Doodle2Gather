public enum DTActionType: String, Codable {
    case add, remove, unremove, modify

    case unknown // handle failed conversion from PersistedDTAction to DTAdaptedAction
}
