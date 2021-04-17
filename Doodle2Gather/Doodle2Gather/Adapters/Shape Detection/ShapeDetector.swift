protocol ShapeDetector {

    /// Takes in a stroke and returns a corrected stroke.
    func processStroke<S: DTStroke>(_ stroke: S) -> S?

}
