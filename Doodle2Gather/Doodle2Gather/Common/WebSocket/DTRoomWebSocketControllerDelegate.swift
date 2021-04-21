import Foundation
import DTSharedLibrary

protocol DTRoomWebSocketControllerDelegate: AnyObject {

    /// Tells the delegate that an action was received and should be dispatched.
    func dispatchAction(_ action: DTActionProtocol)

    /// Tells the delegate to load the current doodles.
    func loadDoodles(_ doodles: [DTDoodleWrapper])

    /// Tells the delegate to add a new doodle.
    func addNewDoodle(_ doodle: DTDoodleWrapper)

    /// Tells the delegate with the user accesses.
    func didUpdateUserAccesses(_ users: [DTAdaptedUserAccesses])

    /// Tells the delegate to update its users.
    func updateUsers(_ users: [DTAdaptedUser])

}
