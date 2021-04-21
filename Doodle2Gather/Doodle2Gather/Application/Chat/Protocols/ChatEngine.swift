protocol ChatEngine {

    /// The delegate for the chat engine. Actions received by the ChatEngine will be dispatched to the delegate.
    var delegate: ChatEngineDelegate? { get set }

    /// Sets up the chat engine based on the current user of the app.
    func initialize()

    /// Tears down the chat channel.
    func tearDown()

    /// Joins a specific messaging channel.
    func joinChannel(channelName: String)
    func send(message: String)
}
