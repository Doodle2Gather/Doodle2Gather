import Foundation

public struct DTClearDrawingMessage: Codable {
    var type = DTMessageType.clearDrawing
    public let id: UUID
    public let roomId: UUID

    public init(id: UUID, roomId: UUID) {
        self.id = id
        self.roomId = roomId
    }
}