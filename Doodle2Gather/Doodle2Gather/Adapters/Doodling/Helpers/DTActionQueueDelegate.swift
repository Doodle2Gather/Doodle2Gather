/// Delegate that listens to a `DTActionQueue`.
protocol DTActionQueueDelegate: AnyObject {

    /// Asks the delegate if an action can be dispatched.
    func canDispatchAction() -> Bool

    /// Dispatches the action without triggering a reload of the canvas.
    func dispatchActionQuietly(_ action: DTNewAction)

}
