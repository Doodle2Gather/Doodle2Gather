protocol StrokeAugmentor {

    /// Takes in a stroke and returns an augmented stroke.
    /// If the augmentation fails or should not occur, the original stroke
    /// will be returned.
    func augmentStroke<S: DTStroke>(_ stroke: S) -> S

}
