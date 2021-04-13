import DTSharedLibrary

protocol ParticipantsDelegate: AnyObject {
    func participantsDidChange() -> [DTUser]
}
