protocol ChatEngine {
    var delegate: ChatEngineDelegate? { get set }
    func initialize()
    func tearDown()
    func joinChannel(channelName: String)
    func send(message: String)
}
