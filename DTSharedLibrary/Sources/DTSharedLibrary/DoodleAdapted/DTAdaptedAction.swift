import Foundation

public struct DTAdaptedAction: Codable {

    public let type: DTActionType
    public let entities: [DTEntityIndexPair]
    public let roomId: UUID
    public let doodleId: UUID
    public let createdBy: String

    public var entityType: DTEntityType? {
        entities.first?.type
    }

    public init(type: DTActionType, entities: [DTEntityIndexPair],
                roomId: UUID, doodleId: UUID, createdBy: String) {
        self.type = type
        self.entities = entities
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdBy = createdBy
    }

    public func getStrokeIndexPairs() -> [DTEntityIndexPair] {
        entities.filter { $0.type == .stroke }
    }

    public func makeStrokes() -> [DTAdaptedStroke] {
        var dtStrokes = [DTAdaptedStroke]()
        for pair in entities where pair.type == .stroke {
            dtStrokes.append(
                DTAdaptedStroke(
                    stroke: pair.entity, strokeId: pair.entityId,
                    roomId: roomId, doodleId: doodleId,
                    createdBy: createdBy, isDeleted: pair.isDeleted
                )
            )
        }
        return dtStrokes
    }

    public func getTextIndexPairs() -> [DTEntityIndexPair] {
        entities.filter { $0.type == .text }
    }

    public func makeText() -> [DTAdaptedText] {
        var dtText = [DTAdaptedText]()
        for pair in entities where pair.type == .text {
            dtText.append(
                DTAdaptedText(
                    text: pair.entity, textId: pair.entityId,
                    roomId: roomId, doodleId: doodleId,
                    createdBy: createdBy, isDeleted: pair.isDeleted
                )
            )
        }
        return dtText
    }

    public func getNewAction(with pairs: [DTEntityIndexPair]) -> DTAdaptedAction {
        DTAdaptedAction(type: type, entities: pairs, roomId: roomId, doodleId: doodleId, createdBy: createdBy)
    }
}

// MARK: - Hashable

extension DTAdaptedAction: Hashable {}
