protocol VideoEngineDelegate: AnyObject {

    /// Dispatches an action when a remote user joins the video call channel.
    func didJoinCall(id: UInt, username: String)

    /// Dispatches an action when a remote user leaves the video call channel.
    func didLeaveCall(id: UInt, username: String)

    /// Dispatches an action when a user's account information is updated.
    func didUpdateUserInfo(id: UInt, username: String)
}
