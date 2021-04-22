import XCTest
import PencilKit
@testable import DTSharedLibrary
@testable import Doodle2Gather

struct DTAdaptedTestHelper {

    static let encoder = JSONEncoder()

    static func createStrokeIndexPair(index: Int = 0, isDeleted: Bool = false) throws -> DTEntityIndexPair {
        let stroke = PencilKitTestHelper.createStroke()
        let data = try XCTUnwrap(encoder.encode(stroke))
        return DTEntityIndexPair(data, index, type: .stroke, entityId: UUID(),
                                 isDeleted: isDeleted)
    }

    static func createPartialAddAction(doodleId: UUID = UUID()) throws -> DTPartialAdaptedAction {
        DTPartialAdaptedAction(type: .add, doodleId: doodleId,
                               strokes: [try createStrokeIndexPair()],
                               createdBy: "userString")
    }

    static func createPartialModifyAction(doodleId: UUID = UUID()) throws -> DTPartialAdaptedAction {
        DTPartialAdaptedAction(type: .modify, doodleId: doodleId,
                               strokes: [try createStrokeIndexPair(), try createStrokeIndexPair()],
                               createdBy: "userString")
    }

    static func createPartialRemoveAction(doodleId: UUID = UUID()) throws -> DTPartialAdaptedAction {
        var strokes = [DTEntityIndexPair]()
        for i in 0..<10 {
            strokes.append(try createStrokeIndexPair(index: i, isDeleted: true))
        }

        return DTPartialAdaptedAction(type: .remove, doodleId: doodleId, strokes: strokes,
                                      createdBy: "userString")
    }

    static func createPartialUnremoveAction(doodleId: UUID = UUID()) throws -> DTPartialAdaptedAction {
        var strokes = [DTEntityIndexPair]()
        for i in 0..<10 {
            strokes.append(try createStrokeIndexPair(index: i))
        }

        return DTPartialAdaptedAction(type: .unremove, doodleId: doodleId, strokes: strokes,
                                      createdBy: "userString")
    }

}
