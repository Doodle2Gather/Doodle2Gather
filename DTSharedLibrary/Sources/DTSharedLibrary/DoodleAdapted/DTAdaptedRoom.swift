import Foundation

/// Represents a room/document
/// A room can contain multiple doodles (aka pages)
/// and users can also start call and use chat inside a room
public struct DTAdaptedRoom: Codable {

    public let ownerId: String
    public let roomId: UUID?
    public let name: String
    public let inviteCode: String
    public var doodles: [DTAdaptedDoodle]

    public init(ownerId: String, name: String, inviteCode: String,
                roomId: UUID? = nil, doodles: [DTAdaptedDoodle] = []) {
        self.ownerId = ownerId
        self.roomId = roomId
        self.name = name
        self.inviteCode = inviteCode
        self.doodles = doodles
    }

    public var doodleCount: Int {
        doodles.count
    }

    public func getDoodle(at index: Int) -> DTAdaptedDoodle {
        doodles[index]
    }

    public mutating func addDoodles(_ doodle: DTAdaptedDoodle) {
        doodles.append(doodle)
    }

}

extension DTAdaptedRoom {
    public struct CreateRequest: Codable {
        public let ownerId: String
        public let name: String

        public init(ownerId: String, name: String) {
            self.ownerId = ownerId
            self.name = name
        }
    }
}

// MARK: - Hashable

extension DTAdaptedRoom: Hashable {}
