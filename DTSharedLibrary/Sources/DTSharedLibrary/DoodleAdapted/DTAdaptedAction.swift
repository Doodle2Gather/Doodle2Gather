import Foundation

public struct DTAdaptedAction: Codable {

    public let type: DTActionType
    public let strokes: [Data]
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: UUID

    public init(type: DTActionType, strokes: [Data], roomId: UUID, doodleId: UUID, createdBy: UUID) {
        self.type = type
        self.strokes = strokes
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
    }

    public func makeStrokes() -> [DTAdaptedStroke] {
        var dtStrokes = [DTAdaptedStroke]()
        for stroke in strokes {
            dtStrokes.append(
                DTAdaptedStroke(
                    stroke: stroke, roomId: roomId, doodleId: doodleId, createdBy: createdBy
                )
            )
        }
        return dtStrokes
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
