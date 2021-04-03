import Foundation

public struct DTAdaptedAction: Codable {

    public let strokesAdded: Set<Data>
    public let strokesRemoved: Set<Data>
    public let roomId: UUID
    public let createdBy: UUID

    public init(strokesAdded: Set<Data>, strokesRemoved: Set<Data>, roomId: UUID, createdBy: UUID) {
        self.strokesAdded = strokesAdded
        self.strokesRemoved = strokesRemoved
        self.roomId = roomId
        self.createdBy = createdBy
    }
    
    public func makeStrokesAdded() -> Set<DTAdaptedStroke> {
        var strokes = Set<DTAdaptedStroke>()
        for stroke in strokesAdded {
            strokes.insert(
                DTAdaptedStroke(
                    stroke: stroke, roomId: roomId, createdBy: createdBy
                )
            )
        }
        return strokes
    }
    
    public func makeStrokesRemoved() -> Set<DTAdaptedStroke> {
        var strokes = Set<DTAdaptedStroke>()
        for stroke in strokesRemoved {
            strokes.insert(
                DTAdaptedStroke(
                    stroke: stroke, roomId: roomId, createdBy: createdBy
                )
            )
        }
        return strokes
    }
    
    func reverse() -> DTAdaptedAction {
        DTAdaptedAction(
            strokesAdded: strokesRemoved,
            strokesRemoved: strokesAdded,
            roomId: roomId, createdBy: createdBy
        )
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
