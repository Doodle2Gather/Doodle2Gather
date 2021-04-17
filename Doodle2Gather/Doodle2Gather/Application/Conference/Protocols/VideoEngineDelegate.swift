protocol VideoEngineDelegate: AnyObject {
    func didJoinCall(id: UInt, username: String)
    func didLeaveCall(id: UInt, username: String)
}
