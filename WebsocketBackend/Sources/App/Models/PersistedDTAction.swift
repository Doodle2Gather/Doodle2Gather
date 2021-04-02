import Fluent
import Vapor
import DoodlingAdaptedLibrary

final class PersistedDTAction: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "room_id")
    var roomId: UUID

    @Field(key: "adding_strokes")
    var addingStrokes: Data

    @Field(key: "removing_strokes")
    var removingStrokes: Data

    @Field(key: "created_by")
    var createdBy: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(roomId: UUID, addingStrokes: Data, removingStrokes: Data, createdBy: UUID, id: UUID? = nil) {
        self.roomId = roomId
        self.addingStrokes = addingStrokes
        self.removingStrokes = removingStrokes
        self.createdBy = createdBy
        self.id = id
    }

    init?(initiateActionMessage: DTInitiateActionMessage) {
        guard let action = DTAdaptedAction(message: initiateActionMessage) else {
            return nil
        }
        self.roomId = action.roomId
        self.addingStrokes = action.addingStrokes
        self.removingStrokes = action.removingStrokes
        self.createdBy = action.createdBy
        self.id = nil
    }

    func getAdaptedAction() -> DTAdaptedAction? {
        DTAdaptedAction(addingStrokes: addingStrokes, removingStrokes: removingStrokes,
                        roomId: roomId, createdBy: createdBy)
    }
}
