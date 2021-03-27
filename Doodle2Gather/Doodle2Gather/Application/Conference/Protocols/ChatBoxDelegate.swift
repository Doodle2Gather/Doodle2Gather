protocol ChatBoxDelegate: AnyObject {
    func onReceiveMessage(_ message: Message)
}
