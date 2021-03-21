/// Delegate for a `DTCanvasView`.
/// It is notified when a doodle for the canvas is changed.
protocol DTCanvasViewDelegate: AnyObject {
    /// Notifies the delegate that the canvas doodle has changed.
    func canvasViewDoodleDidChange(_: DTCanvasView)
}