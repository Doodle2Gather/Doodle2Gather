protocol DTDrawing {
    associatedtype Stroke: DTStroke
    var dtStrokes: Set<Stroke> { get set }

    /// Instantiates self using a generalised `DTDrawing`.
    init<D: DTDrawing>(from drawing: D)
}
