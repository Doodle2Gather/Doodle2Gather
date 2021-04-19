import DTSharedLibrary

/// Represents an action that can be performed.
protocol DTActionProtocol {

    var type: DTActionType { get }
    var strokes: [DTStrokeIndexPair] { get }
    var createdBy: String { get }

    func getStrokes() -> [(stroke: DTStrokeWrapper, index: Int)]
    func inverse() -> Self

}

// MARK: - Default Implementations

extension DTActionProtocol {

    func getStrokes() -> [(stroke: DTStrokeWrapper, index: Int)] {
        var wrappers = [(stroke: DTStrokeWrapper, index: Int)]()

        for stroke in strokes {
            guard let wrapper = DTStrokeWrapper(data: stroke.stroke, strokeId: stroke.strokeId,
                                                createdBy: createdBy, isDeleted: stroke.isDeleted) else {
                continue
            }

            wrappers.append((stroke: wrapper, index: stroke.index))
        }

        return wrappers
    }

}
