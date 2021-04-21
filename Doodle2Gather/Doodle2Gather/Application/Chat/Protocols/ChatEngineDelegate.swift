protocol ChatEngineDelegate: AnyObject {

    /// Dispathces and action when a message is received from the remote server.
    func deliverMessage(from user: String, message: String)
}
