import DTSharedLibrary

protocol ParticipantsDelegate: AnyObject {

    /// Dispatches an action when the states of the current participants in the room change.
    func participantsDidChange(_ participants: [DTUser])
}
