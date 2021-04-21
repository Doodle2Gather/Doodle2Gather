import DTSharedLibrary

protocol InvitationDelegate: AnyObject {

    /// Dispatches an action when the user accesses for the room change.
    func didUpdateUserAccesses(_ accesses: [DTAdaptedUserAccesses])
}
