import DTSharedLibrary

protocol ParticipantsDelegate: AnyObject {
    func participantsDidChange(_ participants: [DTUser])
}
