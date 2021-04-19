import Foundation

public struct DTAdaptedAction: Codable {

    public let type: DTActionType
    public let strokes: [DTStrokeIndexPair]
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: String

    public init(type: DTActionType, strokes: [DTStrokeIndexPair], roomId: UUID, doodleId: UUID, createdBy: String) {
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
                    stroke: stroke.stroke, strokeId: stroke.strokeId,
                    roomId: roomId, doodleId: doodleId,
                    createdBy: createdBy, isDeleted: stroke.isDeleted
                )
            )
        }
        return dtStrokes
    }

    public func getNewAction(with pairs: [DTStrokeIndexPair]) -> DTAdaptedAction {
        DTAdaptedAction(type: type, strokes: pairs, roomId: roomId, doodleId: doodleId, createdBy: createdBy)
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
