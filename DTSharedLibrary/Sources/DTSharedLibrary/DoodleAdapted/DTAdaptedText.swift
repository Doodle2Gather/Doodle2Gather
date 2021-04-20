import Foundation

public struct DTAdaptedText: DTAdaptedEntityProtocol {

    public var type: DTEntityType = .text
    public var entity: Data
    public var entityId: UUID
    public var roomId: UUID
    public var doodleId: UUID
    public var createdBy: String
    public var isDeleted: Bool

    public var text: Data {
        entity
    }

    public var textId: UUID {
        entityId
    }

    public init(text: Data, textId: UUID,
                roomId: UUID, doodleId: UUID,
                createdBy: String, isDeleted: Bool = false) {
        self.entity = text
        self.entityId = textId
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
        self.isDeleted = isDeleted
    }

    public init(_ pair: DTEntityIndexPair, roomId: UUID, doodleId: UUID, createdBy: String) {
        assert(pair.type == .text)

        self.init(text: pair.entity, textId: pair.entityId,
                  roomId: roomId, doodleId: doodleId,
                  createdBy: createdBy, isDeleted: pair.isDeleted)
    }

    public func makeTextIndexPair(index: Int) -> DTEntityIndexPair {
        DTEntityIndexPair(entity, index, type: type, entityId: entityId, isDeleted: isDeleted)
    }
}
