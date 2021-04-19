import Foundation
import DTSharedLibrary

protocol SocketControllerDelegate: AnyObject {

    /// Tells the delegate that an action was received and should be dispatched.
    func dispatchAction(_ action: DTAdaptedAction)

    /// Tells the delegate to load the current doodles.
    func loadDoodles(_ doodles: [DTDoodleWrapper])

    /// Tells the delegate to add a new doodle.
    func addNewDoodle(_ doodle: DTDoodleWrapper)

    /// Tells the delegate to remove the doodle with the given UUID.
    func removeDoodle(doodleId: UUID)

    func updateUsers(_ users: [DTAdaptedUserAccesses])

}
