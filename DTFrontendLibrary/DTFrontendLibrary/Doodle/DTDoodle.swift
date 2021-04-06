import DTSharedLibrary

/// Represents a doodle that contains strokes and can be rendered.
public protocol DTDoodle {
    associatedtype Stroke: DTStroke
    var dtStrokes: [Stroke] { get set }

    /// Instantiates self using a generalised `DTDoodle`.
    init<D: DTDoodle>(from doodle: D)

    /// Instantiates self using data.
    init(from data: DTAdaptedDoodle)

    /// Removes strokes in the given array of strokes from the current array of strokes.
    mutating func removeStrokes<S: DTStroke>(_: [S])

    /// Adds strokes in the given array of strokes to the current array of strokes.
    mutating func addStrokes<S: DTStroke>(_: [S])
}
