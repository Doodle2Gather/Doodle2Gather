import Foundation

public struct DTAdaptedAction: Codable {

    public let type: DTActionType
    public let strokes: [DTStrokeIndexPair]
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: UUID

    public init(type: DTActionType, strokes: [DTStrokeIndexPair], roomId: UUID, doodleId: UUID, createdBy: UUID) {
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
                    stroke: stroke.stroke, roomId: roomId, doodleId: doodleId, createdBy: createdBy
                )
            )
        }
        return dtStrokes
    }
    
    public func getNewAction(with paris: [DTStrokeIndexPair]) -> DTAdaptedAction {
        DTAdaptedAction(type: type, strokes: paris, roomId: roomId, doodleId: doodleId, createdBy: createdBy)
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
