import Foundation

public struct DTDrawingMessage: Codable {
    var type = DTMessageType.drawing
    public let id: UUID
    public let roomId: UUID
    public let strokes: [DTAdaptedStroke]

    public init(id: UUID, strokes: [DTAdaptedStroke], roomId: UUID) {
        self.id = id
        self.roomId = roomId
        self.strokes = strokes
    }
}
