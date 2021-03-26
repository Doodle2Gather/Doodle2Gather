protocol ChatEngineDelegate: AnyObject {
    func deliverMessage(from user: String, message: String)
}
