/// Delegate for a `DTCanvasView`.
/// It is notified when a doodle for the canvas is changed.
protocol DTCanvasViewDelegate: AnyObject {
    
    /// Notifies the delegate that the user has stopped drawing with the tool.
    func canvasViewDidEndUsingTool(_: DTCanvasView)

}
