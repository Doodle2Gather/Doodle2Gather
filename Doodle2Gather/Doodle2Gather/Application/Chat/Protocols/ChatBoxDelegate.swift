protocol ChatBoxDelegate: AnyObject {

    /// Dispatches an action to the chat box when a message from a user is received.
    func onReceiveMessage(_ message: Message)
}
