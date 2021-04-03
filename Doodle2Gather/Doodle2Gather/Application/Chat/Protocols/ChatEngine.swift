protocol ChatEngine {
    var delegate: ChatEngineDelegate? { get set }
    func initialize()
    func joinChannel(channelName: String)
    func send(message: String)
}
