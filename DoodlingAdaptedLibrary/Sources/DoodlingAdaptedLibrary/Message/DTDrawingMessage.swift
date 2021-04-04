import Foundation

public struct DTDrawingMessage: Codable {
    var type = DTMessageType.drawing
    public let roomId: UUID
    public let strokes: [DTAdaptedStroke]

    public init(strokes: [DTAdaptedStroke], roomId: UUID) {
        self.roomId = roomId
        self.strokes = strokes
    }
}
