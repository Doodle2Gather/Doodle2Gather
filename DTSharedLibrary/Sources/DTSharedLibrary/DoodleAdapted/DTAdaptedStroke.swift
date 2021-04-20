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

    public init(_ pair: DTEntityIndexPair, roomId: UUID, doodleId: UUID, createdBy: String) {
        assert(pair.type == .stroke)

        self.init(stroke: pair.entity, strokeId: pair.entityId,
                  roomId: roomId, doodleId: doodleId,
                  createdBy: createdBy, isDeleted: pair.isDeleted)
    }

    public func makeStrokeIndexPair(index: Int) -> DTEntityIndexPair {
        DTEntityIndexPair(entity, index, type: type, entityId: entityId, isDeleted: isDeleted)
    }
}
