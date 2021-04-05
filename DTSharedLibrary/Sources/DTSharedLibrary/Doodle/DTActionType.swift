public enum DTActionType: String, Codable {
    case add, remove, modify
    
    case unknown // handle failed conversion from PersistedDTAction to DTAdaptedAction
}
