import Foundation
import DTSharedLibrary

/// Represents a controller that managers a web socket.
protocol SocketController {

    /// Tells the socket to fire off an action.
    func addAction(_ action: DTAdaptedAction)

    /// Tells the socket that a refetch will be required.
    func refetchDoodles()

    /// Tells the socket to add a new doodle.
    func addDoodle()

    /// Tells the socket to remove the doodle with the given id.
    func removeDoodle(doodleId: UUID)

    /// Tells the socket to disconnect from the room.
    func exitRoom()
}
