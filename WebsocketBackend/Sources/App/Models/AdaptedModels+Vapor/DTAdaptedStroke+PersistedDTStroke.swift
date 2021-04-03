import Vapor
import DoodlingAdaptedLibrary

extension DTAdaptedStroke {
    init(action: PersistedDTStroke) {
        self.init(
            stroke: action.strokeData,
            roomId: action.roomId,
            createdBy: action.createdBy
        )
    }
    
    func makePersistedStroke() -> PersistedDTStroke {
        PersistedDTStroke(
            strokeData: stroke,
            roomId: roomId,
            createdBy: createdBy
        )
    }
}

// MARK: - Content

extension DTAdaptedStroke: Content {}
