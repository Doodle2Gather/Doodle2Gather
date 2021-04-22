import XCTest
import PencilKit
@testable import Doodle2Gather
@testable import DTSharedLibrary

/// Tests the extension of `DTAdaptedAction` to conform to
/// `DTActionProtocol`.
class DTAdaptedActionTests: XCTestCase {

    private let decoder = JSONDecoder()

    func testInit_withPartialAddAction_isCorrect() throws {
        let partialAction = try DTAdaptedTestHelper.createPartialAddAction()
        let roomId = UUID()
        let action = DTAdaptedAction(action: partialAction, roomId: roomId)

        XCTAssertEqual(action.roomId, roomId)
        XCTAssertEqual(action.createdBy, partialAction.createdBy)
        XCTAssertEqual(action.entityType, .stroke)
        XCTAssertEqual(action.doodleId, partialAction.doodleId)
        XCTAssertEqual(action.type, .add)
        XCTAssertEqual(action.entities, partialAction.entities)
    }

    func testInit_withPartialModifyAction_isCorrect() throws {
        let partialAction = try DTAdaptedTestHelper.createPartialModifyAction()
        let roomId = UUID()
        let action = DTAdaptedAction(action: partialAction, roomId: roomId)

        XCTAssertEqual(action.roomId, roomId)
        XCTAssertEqual(action.createdBy, partialAction.createdBy)
        XCTAssertEqual(action.entityType, .stroke)
        XCTAssertEqual(action.doodleId, partialAction.doodleId)
        XCTAssertEqual(action.type, .modify)
        XCTAssertEqual(action.entities, partialAction.entities)
    }

    func testInit_withPartialRemoveAction_isCorrect() throws {
        let partialAction = try DTAdaptedTestHelper.createPartialRemoveAction()
        let roomId = UUID()
        let action = DTAdaptedAction(action: partialAction, roomId: roomId)

        XCTAssertEqual(action.roomId, roomId)
        XCTAssertEqual(action.createdBy, partialAction.createdBy)
        XCTAssertEqual(action.entityType, .stroke)
        XCTAssertEqual(action.doodleId, partialAction.doodleId)
        XCTAssertEqual(action.type, .remove)
        XCTAssertEqual(action.entities, partialAction.entities)
    }

    func testInit_withPartialUnremoveAction_isCorrect() throws {
        let partialAction = try DTAdaptedTestHelper.createPartialUnremoveAction()
        let roomId = UUID()
        let action = DTAdaptedAction(action: partialAction, roomId: roomId)

        XCTAssertEqual(action.roomId, roomId)
        XCTAssertEqual(action.createdBy, partialAction.createdBy)
        XCTAssertEqual(action.entityType, .stroke)
        XCTAssertEqual(action.doodleId, partialAction.doodleId)
        XCTAssertEqual(action.type, .unremove)
        XCTAssertEqual(action.entities, partialAction.entities)
    }

    func testInvert_withAddAction_shouldGiveRemoveAction() throws {
        let action = try createAddAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entityType, action.entityType)
        XCTAssertEqual(invertedAction.roomId, action.roomId)
        XCTAssertEqual(invertedAction.entities.count, 1)
        XCTAssertEqual(invertedAction.type, .remove)
        XCTAssert(invertedAction.entities[0].isDeleted)
        XCTAssertEqual(invertedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertEqual(invertedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(invertedAction.entities[0].type, action.entities[0].type)
        XCTAssertEqual(invertedAction.entities[0].entity, action.entities[0].entity)
    }

    func testInvert_withModifyAction_shouldGiveModifyAction() throws {
        let action = try createModifyAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entityType, action.entityType)
        XCTAssertEqual(invertedAction.roomId, action.roomId)
        XCTAssertEqual(invertedAction.entities.count, 2)
        XCTAssertEqual(invertedAction.type, .modify)
        XCTAssertEqual(invertedAction.entities[0], action.entities[1])
        XCTAssertEqual(invertedAction.entities[1], action.entities[0])
    }

    func testInvert_withRemoveAction_shouldGiveUnremoveAction() throws {
        let action = try createRemoveAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entityType, action.entityType)
        XCTAssertEqual(invertedAction.roomId, action.roomId)
        XCTAssertEqual(invertedAction.entities.count, action.entities.count)
        XCTAssertEqual(invertedAction.type, .unremove)

        for i in 0..<invertedAction.entities.count {
            XCTAssertEqual(invertedAction.entities[i].entity, action.entities[i].entity)
            XCTAssertEqual(invertedAction.entities[i].entityId, action.entities[i].entityId)
            XCTAssertEqual(invertedAction.entities[i].index, action.entities[i].index)
            XCTAssertEqual(invertedAction.entities[i].type, action.entities[i].type)
            XCTAssertFalse(invertedAction.entities[i].isDeleted)
        }
    }

    func testInvert_withUnremoveAction_shouldGiveRemoveAction() throws {
        let action = try createUnremoveAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entityType, action.entityType)
        XCTAssertEqual(invertedAction.roomId, action.roomId)
        XCTAssertEqual(invertedAction.entities.count, action.entities.count)
        XCTAssertEqual(invertedAction.type, .remove)

        for i in 0..<invertedAction.entities.count {
            XCTAssertEqual(invertedAction.entities[i].entity, action.entities[i].entity)
            XCTAssertEqual(invertedAction.entities[i].entityId, action.entities[i].entityId)
            XCTAssertEqual(invertedAction.entities[i].index, action.entities[i].index)
            XCTAssertEqual(invertedAction.entities[i].type, action.entities[i].type)
            XCTAssert(invertedAction.entities[i].isDeleted)
        }
    }

    func testGetStrokes_shouldGiveCorrectStrokes() throws {
        let action = try createRemoveAction()
        let strokes = action.getStrokes()
        XCTAssertEqual(action.entities.count, strokes.count)

        for i in 0..<strokes.count {
            XCTAssertEqual(action.entities[i].entityId, strokes[i].stroke.strokeId)
            let stroke = try XCTUnwrap(decoder.decode(PKStroke.self, from: action.entities[i].entity))
            XCTAssertEqual(stroke, strokes[i].stroke.stroke)
            XCTAssertEqual(action.entities[i].index, strokes[i].index)
            XCTAssertEqual(action.entities[i].isDeleted, strokes[i].stroke.isDeleted)
            XCTAssertEqual(action.createdBy, strokes[i].stroke.createdBy)
            XCTAssertEqual(action.entities[i].type, .stroke)

        }
    }

}

// MARK: - Helper Methods

extension DTAdaptedActionTests {

    private func createAddAction(roomId: UUID = UUID()) throws -> DTAdaptedAction {
        let partialAction = try DTAdaptedTestHelper.createPartialAddAction()
        return DTAdaptedAction(action: partialAction, roomId: roomId)
    }

    private func createModifyAction(roomId: UUID = UUID()) throws -> DTAdaptedAction {
        let partialAction = try DTAdaptedTestHelper.createPartialModifyAction()
        return DTAdaptedAction(action: partialAction, roomId: roomId)
    }

    private func createRemoveAction(roomId: UUID = UUID()) throws -> DTAdaptedAction {
        let partialAction = try DTAdaptedTestHelper.createPartialRemoveAction()
        return DTAdaptedAction(action: partialAction, roomId: roomId)
    }

    private func createUnremoveAction(roomId: UUID = UUID()) throws -> DTAdaptedAction {
        let partialAction = try DTAdaptedTestHelper.createPartialUnremoveAction()
        return DTAdaptedAction(action: partialAction, roomId: roomId)
    }

}
