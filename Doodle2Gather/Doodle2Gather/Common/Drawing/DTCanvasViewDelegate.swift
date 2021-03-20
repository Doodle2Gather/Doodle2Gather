/// Delegate for a `DTCanvasView`.
/// It is notified when a drawing for the canvas is changed.
protocol DTCanvasViewDelegate: AnyObject {
    /// Notifies the delegate that the canvas drawing has changed.
    func canvasViewDrawingDidChange(_: DTCanvasView)
}
