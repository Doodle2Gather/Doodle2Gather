import Foundation

/// Represents a doodle that can contain multiple entities (strokes and text)
/// An adapted model for `DTDoodle`
/// Each doodle belongs to a room
public struct DTAdaptedDoodle: Codable {

    public let roomId: UUID
    public let doodleId: UUID?
    public let createdAt: Date
    public var strokes: [DTAdaptedStroke]

    public init(roomId: UUID, createdAt: Date, doodleId: UUID? = nil,
                strokes: [DTAdaptedStroke] = []) {
        self.strokes = strokes
        self.roomId = roomId
        self.doodleId = doodleId
        self.createdAt = createdAt
    }

    public func getStroke(at index: Int) -> DTAdaptedStroke {
        strokes[index]
    }

    public mutating func addEntity<T: DTAdaptedEntityProtocol>(_ entity: T) {
        switch entity.type {
        case .stroke:
            guard let stroke = entity as? DTAdaptedStroke else {
                return
            }
            strokes.append(stroke)
        }
    }

    public mutating func removeEntity<T: DTAdaptedEntityProtocol>(_ entity: T, at index: Int) {
        switch entity.type {
        case .stroke:
            strokes[index].safeDelete()
        }
    }

    public mutating func unremoveEntity<T: DTAdaptedEntityProtocol>(_ entity: T, at index: Int) {
        switch entity.type {
        case .stroke:
            strokes[index].safeUndelete()
        }
    }

    public mutating func modifyEntity<T: DTAdaptedEntityProtocol>(at index: Int, to newEntity: T) {
        switch newEntity.type {
        case .stroke:
            guard let newStroke = newEntity as? DTAdaptedStroke else {
                return
            }
            strokes[index] = newStroke
        }
    }

    public mutating func removeStroke(at index: Int) {
        strokes[index].safeDelete()
    }

    public mutating func unremoveStroke(at index: Int) {
        strokes[index].safeUndelete()
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
