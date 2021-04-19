import Foundation
import DTSharedLibrary

// MARK: - DTActionProtocol

extension DTAdaptedAction: DTActionProtocol {

    init(partialAction: DTPartialAdaptedAction, roomId: UUID) {
        self.init(type: partialAction.type, strokes: partialAction.strokes, roomId: roomId,
                  doodleId: partialAction.doodleId, createdBy: partialAction.createdBy)
    }

    func inverse() -> DTAdaptedAction {
        var newType: DTActionType = .add
        var newStrokes = strokes

        switch type {
        case .add, .unremove:
            newType = .remove
            newStrokes = [DTStrokeIndexPair(strokes[0].stroke, strokes[0].index,
                                            strokeId: strokes[0].strokeId, isDeleted: true)]
        case .modify:
            newType = .modify
            newStrokes = [strokes[1], strokes[0]]
        case .remove:
            newType = .unremove
            newStrokes = [DTStrokeIndexPair(strokes[0].stroke, strokes[0].index,
                                            strokeId: strokes[0].strokeId, isDeleted: false)]
        case .unknown:
            newType = .unknown
        }

        return DTAdaptedAction(type: newType, strokes: newStrokes, roomId: roomId, doodleId: doodleId,
                               createdBy: createdBy)
    }

}
