import XCTest
@testable import Doodle2Gather
@testable import DTSharedLibrary

// MARK: - Transform Action

extension DTActionManagerTests {

    func testTransformAddAction_newStrokesAdded_transformsCorrectly() {
        let newStrokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        let newStrokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        doodleOne.strokes.append(newStrokeOne)

        guard let action = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                                  strokes: [(newStrokeTwo, 10)], createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }
        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, .add)
        XCTAssertEqual(transformedAction.entities.count, 1)
        XCTAssertEqual(transformedAction.entities[0].index, 11)
        XCTAssertEqual(transformedAction.entities[0].entityId, newStrokeTwo.strokeId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
    }

    func testTransformAddAction_fewerStrokes_transformsCorrectly() {
        let newStroke = DTAdaptedTestHelper.createStrokeWrapper()
        doodleOne.strokes.remove(at: 5)
        doodleOne.strokes.remove(at: 6)

        guard let action = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                                  strokes: [(newStroke, 10)], createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }
        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, .add)
        XCTAssertEqual(transformedAction.entities.count, 1)
        XCTAssertEqual(transformedAction.entities[0].index, 8)
        XCTAssertEqual(transformedAction.entities[0].entityId, newStroke.strokeId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
    }

    func testTransformAddAction_noChangeInStrokes_sameAction() {
        let newStroke = DTAdaptedTestHelper.createStrokeWrapper()

        guard let action = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                                  strokes: [(newStroke, 10)], createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }
        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, action.entities.count)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
    }

    func testTransformRemoveAction_noChangeInStrokes_sameAction() {
        var strokeOne = doodleOne.strokes[3]
        strokeOne.isDeleted = true
        var strokeTwo = doodleOne.strokes[6]
        strokeTwo.isDeleted = true

        guard let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }

        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, action.entities.count)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(transformedAction.entities[1].index, action.entities[1].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertEqual(transformedAction.entities[1].entityId, action.entities[1].entityId)
        XCTAssert(transformedAction.entities[0].isDeleted)
        XCTAssert(transformedAction.entities[1].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
        XCTAssertEqual(transformedAction.entities[1].entity, action.entities[1].entity)
    }

    func testTransformRemoveAction_someStrokesRemoved_transformsAction() {
        var strokeOne = doodleOne.strokes[3]
        strokeOne.isDeleted = true
        var strokeTwo = doodleOne.strokes[6]
        strokeTwo.isDeleted = true
        doodleOne.strokes[6].isDeleted = true

        guard let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }

        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, 1)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssert(transformedAction.entities[0].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
    }

    func testTransformRemoveAction_allStrokesRemoved_returnsNil() {
        var strokeOne = doodleOne.strokes[3]
        strokeOne.isDeleted = true
        var strokeTwo = doodleOne.strokes[6]
        strokeTwo.isDeleted = true
        doodleOne.strokes[3].isDeleted = true
        doodleOne.strokes[6].isDeleted = true

        guard let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }
        XCTAssertNil(actionManager.transformAction(action, on: doodleOne))
    }

    func testTransformUnremoveAction_noChangeInStrokes_sameAction() {
        let strokeOne = doodleOne.strokes[3]
        doodleOne.strokes[3].isDeleted = true
        let strokeTwo = doodleOne.strokes[6]
        doodleOne.strokes[6].isDeleted = true

        guard let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }

        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, action.entities.count)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(transformedAction.entities[1].index, action.entities[1].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertEqual(transformedAction.entities[1].entityId, action.entities[1].entityId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertFalse(transformedAction.entities[1].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
        XCTAssertEqual(transformedAction.entities[1].entity, action.entities[1].entity)
    }

    func testTransformUnremoveAction_someStrokesUnremoved_transformsAction() {
        let strokeOne = doodleOne.strokes[3]
        let strokeTwo = doodleOne.strokes[6]
        doodleOne.strokes[6].isDeleted = true

        guard let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }

        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, 1)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[1].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[1].entityId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[1].entity)
    }

    func testTransformUnremoveAction_allStrokesUnremoved_returnsNil() {
        let strokeOne = doodleOne.strokes[3]
        let strokeTwo = doodleOne.strokes[6]

        guard let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 6)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }
        XCTAssertNil(actionManager.transformAction(action, on: doodleOne))
    }

    func testTransformModifyAction_noChangeInStrokes_sameAction() {
        let strokeOne = doodleOne.strokes[3]
        let strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()

        guard let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 3)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }

        guard let transformedAction = actionManager.transformAction(action, on: doodleOne) else {
            XCTFail("Should transform action")
            return
        }

        assertActionProperties(transformedAction)
        XCTAssertEqual(transformedAction.type, action.type)
        XCTAssertEqual(transformedAction.entities.count, action.entities.count)
        XCTAssertEqual(transformedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(transformedAction.entities[1].index, action.entities[1].index)
        XCTAssertEqual(transformedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertEqual(transformedAction.entities[1].entityId, action.entities[1].entityId)
        XCTAssertFalse(transformedAction.entities[0].isDeleted)
        XCTAssertFalse(transformedAction.entities[1].isDeleted)
        XCTAssertEqual(transformedAction.entities[0].entity, action.entities[0].entity)
        XCTAssertEqual(transformedAction.entities[1].entity, action.entities[1].entity)
    }

    func testTransformModifyAction_strokeModified_returnsNil() {
        let strokeOne = doodleOne.strokes[3]
        let strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        doodleOne.strokes[3] = DTAdaptedTestHelper.createStrokeWrapper()

        guard let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                                  strokes: [(strokeOne, 3), (strokeTwo, 3)],
                                                  createdBy: "Testing") else {
            XCTFail("Should create action")
            return
        }
        XCTAssertNil(actionManager.transformAction(action, on: doodleOne))
    }

}

// MARK: - Undo / Redo

extension DTActionManagerTests {

    func testUndo_noActionAdded_returnsNil() {
        XCTAssertNil(actionManager.undo())
    }

    // Test using one type of action. The actual inversion logic tests
    // will be with the models instead.
    func testUndo_oneActionAdded_returnsInvertedAction() {
        actionManager.addNewActionToUndo(actionOne)
        guard let undoneAction = actionManager.undo() else {
            XCTFail("Should create undone action")
            return
        }
        XCTAssertEqual(undoneAction.type, .remove)
        XCTAssertEqual(undoneAction.createdBy, actionOne.createdBy)
        XCTAssertEqual(undoneAction.doodleId, actionOne.doodleId)
        XCTAssertEqual(undoneAction.entities[0].entityId, actionOne.entities[0].entityId)
        XCTAssertEqual(undoneAction.entities[0].entity, actionOne.entities[0].entity)
        XCTAssertEqual(undoneAction.entities[0].index, actionOne.entities[0].index)
        XCTAssert(undoneAction.entities[0].isDeleted)
    }

    func testUndo_twoActionsAdded_returnsInvertedLastAction() {
        actionManager.addNewActionToUndo(actionOne)
        actionManager.addNewActionToUndo(actionTwo)
        guard let undoneAction = actionManager.undo() else {
            XCTFail("Should create undone action")
            return
        }

        XCTAssertEqual(undoneAction.entities[0].entityId, actionTwo.entities[0].entityId)
        XCTAssertEqual(undoneAction.entities[0].entity, actionTwo.entities[0].entity)
        XCTAssertEqual(undoneAction.entities[0].index, actionTwo.entities[0].index)
    }

    func testRedo_noActionUndone_returnsNil() {
        XCTAssertNil(actionManager.redo())
    }

    func testRedo_oneActionUndone_returnsInvertedAction() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        guard let redoneAction = actionManager.redo() else {
            XCTFail("Should create redone action")
            return
        }
        XCTAssertEqual(redoneAction.type, .unremove)
        XCTAssertEqual(redoneAction.createdBy, actionOne.createdBy)
        XCTAssertEqual(redoneAction.doodleId, actionOne.doodleId)
        XCTAssertEqual(redoneAction.entities[0].entityId, actionOne.entities[0].entityId)
        XCTAssertEqual(redoneAction.entities[0].entity, actionOne.entities[0].entity)
        XCTAssertEqual(redoneAction.entities[0].index, actionOne.entities[0].index)
        XCTAssertFalse(redoneAction.entities[0].isDeleted)
    }

    func testRedo_twoActionsUndone_returnsInvertedLastAction() {
        actionManager.addNewActionToUndo(actionOne)
        actionManager.addNewActionToUndo(actionTwo)
        _ = actionManager.undo()
        _ = actionManager.undo()
        guard let redoneAction = actionManager.redo() else {
            XCTFail("Should create redone action")
            return
        }

        XCTAssertEqual(redoneAction.type, .unremove)
        XCTAssertEqual(redoneAction.entities[0].entityId, actionOne.entities[0].entityId)
        XCTAssertEqual(redoneAction.entities[0].entity, actionOne.entities[0].entity)
        XCTAssertEqual(redoneAction.entities[0].index, actionOne.entities[0].index)
    }

    func testRedo_actionUndoneThenNewActionAdded_returnsNil() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        actionManager.addNewActionToUndo(actionTwo)
        XCTAssertNil(actionManager.redo())
    }

    func testCanUndo_noActionAdded_isFalse() {
        XCTAssertFalse(actionManager.canUndo)
    }

    func testCanUndo_actionAdded_isTrue() {
        actionManager.addNewActionToUndo(actionOne)
        XCTAssert(actionManager.canUndo)
    }

    func testCanUndo_actionAddedThenUndone_isFalse() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        XCTAssertFalse(actionManager.canUndo)
    }

    func testCanRedo_noActionUndone_isFalse() {
        XCTAssertFalse(actionManager.canRedo)
    }

    func testCanRedo_actionUndone_isTrue() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        XCTAssert(actionManager.canRedo)
    }

    func testCanRedo_actionUndoneThenRedone_isFalse() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        _ = actionManager.redo()
        XCTAssertFalse(actionManager.canRedo)
    }

    func testCanRedo_actionUndoneThenNewActionAdded_isFalse() {
        actionManager.addNewActionToUndo(actionOne)
        _ = actionManager.undo()
        actionManager.addNewActionToUndo(actionTwo)
        XCTAssertFalse(actionManager.canRedo)
    }

}
