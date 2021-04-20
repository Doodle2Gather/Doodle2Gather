import Foundation
import DTSharedLibrary

protocol DTConferenceWebSocketControllerDelegate: AnyObject {

    /// Tells the delegate that some user has changed their conferencing state(s).
    func updateStates(_ users: [DTAdaptedUserVideoConferenceState])

}
