import Foundation

public struct DTAdaptedDoodle: Codable {

    public let roomId: UUID
    public let doodleId: UUID?
    public let createdAt: Date
    public var strokes: [DTAdaptedStroke]
    public var text: [DTAdaptedText]

    public init(roomId: UUID, createdAt: Date, doodleId: UUID? = nil,
                strokes: [DTAdaptedStroke] = [], text: [DTAdaptedText] = []) {
        self.strokes = strokes
        self.text = text
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdAt = createdAt
    }

    public func getStroke(at index: Int) -> DTAdaptedStroke {
        strokes[index]
    }

    public func getText(at index: Int) -> DTAdaptedText {
        text[index]
    }

    public mutating func addEntity<T: DTAdaptedEntityProtocol>(_ entity: T) {
        switch entity.type {
        case .stroke:
            guard let stroke = entity as? DTAdaptedStroke else {
                return
            }
            strokes.append(stroke)
        case .text:
            guard let text = entity as? DTAdaptedText else {
                return
            }
            self.text.append(text)
        }
    }

    public mutating func removeEntity<T: DTAdaptedEntityProtocol>(_ entity: T, at index: Int) {
        switch entity.type {
        case .stroke:
            strokes[index].safeDelete()
        case .text:
            text[index].safeDelete()
        }
    }

    public mutating func unremoveEntity<T: DTAdaptedEntityProtocol>(_ entity: T, at index: Int) {
        switch entity.type {
        case .stroke:
            strokes[index].safeUndelete()
        case .text:
            text[index].safeUndelete()
        }
    }

    public mutating func modifyEntity<T: DTAdaptedEntityProtocol>(at index: Int, to newEntity: T) {
        switch newEntity.type {
        case .stroke:
            guard let newStroke = newEntity as? DTAdaptedStroke else {
                return
            }
            strokes[index] = newStroke
        case .text:
            guard let newText = newEntity as? DTAdaptedText else {
                return
            }
            text[index] = newText
        }
    }

    public mutating func removeStroke(at index: Int) {
        strokes[index].safeDelete()
    }

    public mutating func unremoveStroke(at index: Int) {
        strokes[index].safeUndelete()
    }

    public mutating func removeText(at index: Int) {
        text[index].safeDelete()
    }

    public mutating func unremoveText(at index: Int) {
        text[index].safeUndelete()
    }

}

extension DTAdaptedDoodle {
    public struct CreateRequest: Codable {
        public let roomId: UUID

        public init(roomId: UUID) {
            self.roomId = roomId
        }
    }
}

// MARK: - Hashable

extension DTAdaptedDoodle: Hashable {}
