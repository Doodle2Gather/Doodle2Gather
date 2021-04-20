import Foundation

public struct DTAdaptedStroke: DTAdaptedEntityProtocol {

    public var type: DTEntityType = .stroke
    public var entity: Data
    public var entityId: UUID
    public var roomId: UUID
    public var doodleId: UUID
    public var createdBy: String
    public var isDeleted: Bool

    public var stroke: Data {
        entity
    }

    public var strokeId: UUID {
        entityId
    }

    public init(stroke: Data, strokeId: UUID,
                roomId: UUID, doodleId: UUID,
                createdBy: String, isDeleted: Bool = false) {
        self.entity = stroke
        self.entityId = strokeId
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
        self.isDeleted = isDeleted
    }

    public init(_ strokeIndexPair: DTStrokeIndexPair, roomId: UUID, doodleId: UUID, createdBy: String) {
        self.init(stroke: strokeIndexPair.stroke, strokeId: strokeIndexPair.strokeId,
                  roomId: roomId, doodleId: doodleId,
                  createdBy: createdBy, isDeleted: strokeIndexPair.isDeleted)
    }
}
