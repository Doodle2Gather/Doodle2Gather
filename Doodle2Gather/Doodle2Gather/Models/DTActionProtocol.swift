import Foundation
import DTSharedLibrary

/// Represents an action that can be performed.
protocol DTActionProtocol {

    /// Type of action performed.
    var type: DTActionType { get }
    
    /// The entities and their indices that make up this action.
    var entities: [DTEntityIndexPair] { get }
    
    /// The ID string of the user that created this action.
    var createdBy: String { get }
    
    /// The ID of the doodle that this action is applicable for.
    var doodleId: UUID { get }

    /// Transforms the `DTEntityIndexPair`s into tuples of `DTStrokeWrapper`
    /// and their indices.
    func getStrokes() -> [(stroke: DTStrokeWrapper, index: Int)]
    
    /// Inverts the action.
    func invert() -> Self

}

// MARK: - Default Implementations

extension DTActionProtocol {

    func getStrokes() -> [(stroke: DTStrokeWrapper, index: Int)] {
        var wrappers = [(stroke: DTStrokeWrapper, index: Int)]()

        for stroke in entities {
            guard let wrapper = DTStrokeWrapper(data: stroke.entity, strokeId: stroke.entityId,
                                                createdBy: createdBy, isDeleted: stroke.isDeleted) else {
                continue
            }
            wrappers.append((stroke: wrapper, index: stroke.index))
        }

        return wrappers
    }

}
