import Foundation

public struct DTAdaptedAction {

    public let strokesAdded: Set<Data>
    public let strokesRemoved: Set<Data>
    public let addingStrokes: Data
    public let removingStrokes: Data
    public let roomId: UUID
    public let createdBy: UUID

    public init?(strokesAdded: Set<Data>, strokesRemoved: Set<Data>, roomId: UUID, createdBy: UUID) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        
        guard let (adding, removing) = DTAdaptedAction.encodeStrokesIntoAction(added: strokesAdded, removed: strokesRemoved) else {
            return nil
        }
        addingStrokes = adding
        removingStrokes = removing
        self.roomId = roomId
        self.createdBy = createdBy
    }
    
    public init?(addingStrokes: Data, removingStrokes: Data, roomId: UUID, createdBy: UUID) {
        self.addingStrokes = addingStrokes
        self.removingStrokes = removingStrokes
        
        guard let (added, removed) = DTAdaptedAction.decodeActionToStrokes(adding: addingStrokes, removing: removingStrokes) else {
            return nil
        }
        strokesAdded = added
        strokesRemoved = removed
        self.roomId = roomId
        self.createdBy = createdBy
    }
    
    public init?(message: DTInitiateActionMessage) {
        strokesAdded = message.strokesAdded
        strokesRemoved = message.strokesRemoved
        
        guard let (adding, removing) = DTAdaptedAction.encodeStrokesIntoAction(added: strokesAdded, removed: strokesRemoved) else {
            return nil
        }
        
        addingStrokes = adding
        removingStrokes = removing
        self.roomId = message.roomId
        self.createdBy = message.id
    }
    
    static func encodeStrokesIntoAction(added: Set<Data>, removed: Set<Data>) -> (adding: Data, removing: Data)? {
        let encoder = JSONEncoder()
        guard let adding = try? encoder.encode(added),
              let removing = try? encoder.encode(removed) else {
            return nil
        }
        return (adding, removing)
    }
    
    static func decodeActionToStrokes(adding: Data, removing: Data) -> (added: Set<Data>, removed: Set<Data>)? {
        let decoder = JSONDecoder()
        guard let added = try? decoder.decode(Set<Data>.self, from: adding),
              let removed = try? decoder.decode(Set<Data>.self, from: removing) else {
            return nil
        }
        return (added, removed)
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {

}
