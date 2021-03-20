/// Delegate for a `CanvasController`.
protocol CanvasControllerDelegate: AnyObject {
    /// Notifies the delegate that an action has been completed.
    func actionDidFinish(action: DTAction)
}

// MARK: - Default Implementation

extension CanvasControllerDelegate {
    func actionDidFinish(action: DTAction) {
        // Do nothing
    }
}
