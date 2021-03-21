/// Represents a doodle that contains strokes and can be rendered.
protocol DTDoodle {
    associatedtype Stroke: DTStroke
    var dtStrokes: Set<Stroke> { get set }

    /// Instantiates self using a generalised `DTDoodle`.
    init<D: DTDoodle>(from doodle: D)

    /// Removes strokes in the given set of strokes from the current set.
    mutating func removeStrokes<S: DTStroke>(_: Set<S>)

    /// Adds strokes in the given set of strokes to the current set.
    mutating func addStrokes<S: DTStroke>(_: Set<S>)
}
