protocol ChatBoxDelegate: AnyObject {
    func onReceiveMessage(from user: String, message: String)
}
