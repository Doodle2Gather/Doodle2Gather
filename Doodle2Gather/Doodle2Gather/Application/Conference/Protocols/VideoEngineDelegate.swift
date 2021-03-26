protocol VideoEngineDelegate: AnyObject {
    func didJoinCall(id: UInt)
    func didLeaveCall(id: UInt)
}
