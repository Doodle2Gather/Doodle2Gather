protocol VideoEngine {
    var delegate: VideoEngineDelegate? { get set }
    func initialize()
    func tearDown()
    func joinChannel(channelName: String)
    func muteAudio()
    func unmuteAudio()
    func showVideo()
    func hideVideo()
    func setupLocalUserView(view: VideoCollectionViewCell)
    func setupRemoteUserView(view: VideoCollectionViewCell, id: UInt)
    func getUserInfo(uid: UInt) -> String
}
