protocol VideoEngine {

    /// Sets up the video engine based on the current user of the app.
    var delegate: VideoEngineDelegate? { get set }

    /// The delegate for the video engine.
    func initialize()

    /// Tears down the video channel.
    func tearDown()

    /// Joins a specific video call channel of the specified name.
    func joinChannel(channelName: String)

    /// Mutes the user’s audio.
    func muteAudio()

    /// Unmutes the user’s audio.
    func unmuteAudio()

    /// Displays the user’s video.
    func showVideo()

    /// Hides the user’s video.
    func hideVideo()

    /// Sets up the video stream view for the user.
    func setupLocalUserView(view: VideoCollectionViewCell)

    /// Sets up the video stream view for the remote users in the same call.
    func setupRemoteUserView(view: VideoCollectionViewCell, id: UInt)

    /// Fetches the user account information from the user's uid.
    func getUserInfo(uid: UInt) -> String
}
