import Foundation

public protocol DTAdaptedEntityProtocol: Codable, Hashable {

    var type: DTEntityType { get }
    var entity: Data { get }
    var entityId: UUID { get }
    var roomId: UUID { get }
    var doodleId: UUID { get }
    var createdBy: String { get }
    var isDeleted: Bool { get set }

}

// MARK: - Hashable

extension DTAdaptedEntityProtocol {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.doodleId != rhs.doodleId {
            print("wrong doodle id")
        }
        if lhs.roomId != rhs.roomId {
            print("wrong room id")
        }
        if lhs.entityId != rhs.entityId {
            print("wrong entityId id")
        }
        return lhs.entityId == rhs.entityId &&
            lhs.roomId == rhs.roomId &&
            lhs.doodleId == rhs.doodleId
    }

    mutating func safeDelete() {
        isDeleted = true
    }

    mutating func safeUndelete() {
        isDeleted = false
    }

    public func makeEntityIndexPair(index: Int) -> DTEntityIndexPair {
        DTEntityIndexPair(entity, index, type: type, entityId: entityId, isDeleted: isDeleted)
    }

}
