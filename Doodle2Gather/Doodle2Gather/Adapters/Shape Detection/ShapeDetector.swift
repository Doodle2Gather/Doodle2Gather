import DTFrontendLibrary

protocol ShapeDetector {

    /// Takes in a stroke and returns a corrected stroke.
    /// May mutate the object if state persistence is required.
    mutating func processStroke<S: DTStroke>(_ stroke: S) -> S?

}
