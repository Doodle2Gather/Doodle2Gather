import Foundation

public struct DTAdaptedRoom: Codable {

    public let ownerId: UUID
    public let roomId: UUID?
    public let name: String
    public let inviteCode: String
    public var doodles: [DTAdaptedDoodle]

    public init(ownerId: UUID, roomId: UUID? = nil,
                name: String, inviteCode: String,
                doodles: [DTAdaptedDoodle] = []) {
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

// MARK: - Hashable

extension DTAdaptedRoom: Hashable {}
