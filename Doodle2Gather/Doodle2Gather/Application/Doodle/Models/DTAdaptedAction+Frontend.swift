import Foundation
import DTSharedLibrary

// MARK: - Frontend Extensions

extension DTAdaptedAction {

    init(partialAction: DTPartialAction, roomId: UUID) {
        self.init(type: partialAction.type, strokes: partialAction.strokes, roomId: roomId,
                  doodleId: partialAction.doodleId, createdBy: partialAction.createdBy)
    }

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
