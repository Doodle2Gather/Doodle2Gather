import XCTest
@testable import Doodle2Gather
@testable import DTSharedLibrary

// MARK: - Create Actions

class DTActionManagerTests: XCTestCase {

    var actionManager = DTActionManager()
    let encoder = JSONEncoder()
    var doodleOne = DTDoodleWrapper()
    var doodleTwo = DTDoodleWrapper()

    var strokeOne = DTAdaptedTestHelper.createStrokeWrapper()
    var strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
    var actionOne = DTPartialAdaptedAction(type: .remove, doodleId: UUID(),
                                           strokes: [DTEntityIndexPair](),
                                           createdBy: "Testing")
    var actionTwo = DTPartialAdaptedAction(type: .remove, doodleId: UUID(),
                                           strokes: [DTEntityIndexPair](),
                                           createdBy: "Testing")

    override func setUpWithError() throws {
        try super.setUpWithError()
        actionManager = DTActionManager()
        actionManager.userId = "Testing"

        let adaptedDoodle = try DTAdaptedTestHelper.createAdaptedDoodle()
        doodleOne = DTDoodleWrapper(doodle: adaptedDoodle)
        doodleTwo = DTDoodleWrapper(doodle: adaptedDoodle)

        strokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        strokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        actionOne = try XCTUnwrap(DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                                         strokes: [(strokeOne, 10)], createdBy: "Testing"))
        actionTwo = try XCTUnwrap(DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                                         strokes: [(strokeTwo, 5)], createdBy: "Testing"))
    }

    func assertActionProperties(_ action: DTActionProtocol) {
        XCTAssertEqual(action.createdBy, "Testing")
        XCTAssertEqual(action.doodleId, doodleOne.doodleId)
    }

    func testCreateAddAction_oneStrokeAdded_createsAction() throws {
        let newStroke = DTAdaptedTestHelper.createStrokeWrapper()
        doodleTwo.strokes.append(newStroke)
        guard let action = actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                      actionType: .add) else {
            XCTFail("Should create valid action")
            return
        }

        assertActionProperties(action)
        XCTAssertEqual(action.type, .add)
        XCTAssertEqual(action.entities.count, 1)
        XCTAssertEqual(action.entities[0].index, doodleTwo.strokes.count - 1)
        XCTAssertFalse(action.entities[0].isDeleted)
        XCTAssertEqual(action.entities[0].entity, try encoder.encode(newStroke.stroke))
    }

    func testCreateAddAction_noStrokeAdded_returnsNil() {
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .add))
    }

    func testCreateAddAction_twoStrokesAdded_returnsNil() {
        let newStrokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        let newStrokeTwo = DTAdaptedTestHelper.createStrokeWrapper()
        doodleTwo.strokes.append(newStrokeOne)
        doodleTwo.strokes.append(newStrokeTwo)
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .add))
    }

    func testCreateRemoveAction_oneStrokeRemoved_createsAction() {
        let removedStroke = doodleTwo.strokes[3]
        doodleTwo.strokes[3].isDeleted = true
        guard let action = actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                      actionType: .remove) else {
            XCTFail("Should create valid action")
            return
        }

        assertActionProperties(action)
        XCTAssertEqual(action.type, .remove)
        XCTAssertEqual(action.entities.count, 1)
        XCTAssertEqual(action.entities[0].index, 3)
        XCTAssert(action.entities[0].isDeleted)
        XCTAssertEqual(action.entities[0].entity, try encoder.encode(removedStroke.stroke))
    }

    func testCreateRemoveAction_noStrokeRemoved_returnsNil() {
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .remove))
    }

    func testCreateRemoveAction_multipleStrokesRemoved_createsAction() {
        let removedStrokeOne = doodleTwo.strokes[2]
        doodleTwo.strokes[2].isDeleted = true
        let removedStrokeTwo = doodleTwo.strokes[5]
        doodleTwo.strokes[5].isDeleted = true
        let removedStrokeThree = doodleTwo.strokes[7]
        doodleTwo.strokes[7].isDeleted = true
        guard let action = actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                      actionType: .remove) else {
            XCTFail("Should create valid action")
            return
        }

        assertActionProperties(action)
        XCTAssertEqual(action.type, .remove)
        XCTAssertEqual(action.entities.count, 3)
        XCTAssertEqual(action.entities[0].index, 2)
        XCTAssertEqual(action.entities[1].index, 5)
        XCTAssertEqual(action.entities[2].index, 7)
        XCTAssert(action.entities[0].isDeleted)
        XCTAssert(action.entities[1].isDeleted)
        XCTAssert(action.entities[2].isDeleted)
        XCTAssertEqual(action.entities[0].entity, try encoder.encode(removedStrokeOne.stroke))
        XCTAssertEqual(action.entities[1].entity, try encoder.encode(removedStrokeTwo.stroke))
        XCTAssertEqual(action.entities[2].entity, try encoder.encode(removedStrokeThree.stroke))
    }

    func testCreateModifyAction_oneStrokeModified_createsAction() {
        let originalStroke = doodleTwo.strokes[3]
        let newStroke = DTAdaptedTestHelper.createStrokeWrapper()
        doodleTwo.strokes[3] = newStroke
        guard let action = actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                      actionType: .modify) else {
            XCTFail("Should create valid action")
            return
        }

        assertActionProperties(action)
        XCTAssertEqual(action.type, .modify)
        XCTAssertEqual(action.entities.count, 2)
        XCTAssertEqual(action.entities[0].index, 3)
        XCTAssertEqual(action.entities[1].index, 3)
        XCTAssertNotEqual(action.entities[0].entityId, action.entities[1].entityId)
        XCTAssertFalse(action.entities[0].isDeleted)
        XCTAssertFalse(action.entities[1].isDeleted)
        XCTAssertEqual(action.entities[0].entity, try encoder.encode(originalStroke.stroke))
        XCTAssertEqual(action.entities[1].entity, try encoder.encode(newStroke.stroke))
    }

    func testCreateModifyAction_noStrokeModified_returnsNil() {
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .modify))
    }

    func testCreateModifyAction_multipleStrokesModified_createsActionForFirstModifiedStroke() {
        let originalStrokeOne = doodleTwo.strokes[3]
        let newStrokeOne = DTAdaptedTestHelper.createStrokeWrapper()
        doodleTwo.strokes[3] = newStrokeOne
        doodleTwo.strokes[6] = DTAdaptedTestHelper.createStrokeWrapper()
        guard let action = actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                      actionType: .modify) else {
            XCTFail("Should create valid action")
            return
        }

        assertActionProperties(action)
        XCTAssertEqual(action.type, .modify)
        XCTAssertEqual(action.entities.count, 2)
        XCTAssertEqual(action.entities[0].index, 3)
        XCTAssertEqual(action.entities[1].index, 3)
        XCTAssertNotEqual(action.entities[0].entityId, action.entities[1].entityId)
        XCTAssertFalse(action.entities[0].isDeleted)
        XCTAssertFalse(action.entities[1].isDeleted)
        XCTAssertEqual(action.entities[0].entity, try encoder.encode(originalStrokeOne.stroke))
        XCTAssertEqual(action.entities[1].entity, try encoder.encode(newStrokeOne.stroke))
    }

    func testCreateUnremoveAction_returnsNil() {
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .unremove))
        doodleOne.strokes[3].isDeleted = true
        doodleTwo.strokes[3].isDeleted = false
        XCTAssertNil(actionManager.createAction(oldDoodle: doodleOne, newDoodle: doodleTwo.drawing,
                                                actionType: .unremove))
    }

}

// MARK: - Apply Actions

extension DTActionManagerTests {

    func testApplyAddAction_validAction_appliesAction() throws {
        let stroke = try DTAdaptedTestHelper.createStrokeIndexPair(numberOfPoints: 10, index: 10, isDeleted: false)
        let action = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                            strokes: [stroke], createdBy: "Testing")
        XCTAssertEqual(doodleOne.strokes.count, 10)
        let newDoodle = try XCTUnwrap(actionManager.applyAction(action, on: doodleOne))
        XCTAssertEqual(newDoodle.strokes.count, 11)
        XCTAssertEqual(try encoder.encode(newDoodle.strokes[10].stroke), stroke.entity)
    }

    func testApplyAddAction_invalidIndex_returnsNil() throws {
        let strokeOne = try DTAdaptedTestHelper.createStrokeIndexPair(numberOfPoints: 10, index: 11, isDeleted: false)
        let actionOne = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                               strokes: [strokeOne], createdBy: "Testing")
        let strokeTwo = try DTAdaptedTestHelper.createStrokeIndexPair(numberOfPoints: 10, index: 5, isDeleted: false)
        let actionTwo = DTPartialAdaptedAction(type: .add, doodleId: doodleOne.doodleId,
                                               strokes: [strokeTwo], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionOne, on: doodleOne))
        XCTAssertNil(actionManager.applyAction(actionTwo, on: doodleOne))
    }

    func testApplyRemoveAction_validAction_appliesAction() throws {
        let stroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                       type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                       isDeleted: true)
        let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                            strokes: [stroke], createdBy: "Testing")
        XCTAssertEqual(doodleOne.strokes.count, 10)
        XCTAssertEqual(doodleOne.drawing.dtStrokes.count, 10)
        let newDoodle = try XCTUnwrap(actionManager.applyAction(action, on: doodleOne))
        XCTAssertEqual(newDoodle.strokes.count, 10)
        XCTAssertEqual(newDoodle.drawing.dtStrokes.count, 9)
        XCTAssert(newDoodle.strokes[4].isDeleted)
    }

    func testApplyRemoveAction_invalidIndex_returnsNil() throws {
        let strokeOne = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 10,
                                          type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                          isDeleted: true)
        let actionOne = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                               strokes: [strokeOne], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionOne, on: doodleOne))
        let strokeTwo = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), -1,
                                          type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                          isDeleted: true)
        let actionTwo = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                               strokes: [strokeTwo], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionTwo, on: doodleOne))
    }

    func testApplyRemoveAction_invalidStrokeId_returnsNil() throws {
        let stroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                       type: .stroke, entityId: doodleOne.strokes[5].strokeId,
                                       isDeleted: true)
        let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleOne.doodleId,
                                            strokes: [stroke], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(action, on: doodleOne))
    }

    func testApplyUnremoveAction_validAction_appliesAction() throws {
        doodleOne.strokes[4].isDeleted = true
        let stroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                       type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                       isDeleted: false)
        let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                            strokes: [stroke], createdBy: "Testing")
        XCTAssertEqual(doodleOne.strokes.count, 10)
        XCTAssertEqual(doodleOne.drawing.dtStrokes.count, 9)
        let newDoodle = try XCTUnwrap(actionManager.applyAction(action, on: doodleOne))
        XCTAssertEqual(newDoodle.strokes.count, 10)
        XCTAssertEqual(newDoodle.drawing.dtStrokes.count, 10)
        XCTAssertFalse(newDoodle.strokes[4].isDeleted)
    }

    func testApplyUnremoveAction_invalidIndex_returnsNil() throws {
        doodleOne.strokes[4].isDeleted = true
        let strokeOne = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 10,
                                          type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                          isDeleted: false)
        let actionOne = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                               strokes: [strokeOne], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionOne, on: doodleOne))
        let strokeTwo = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), -1,
                                          type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                          isDeleted: false)
        let actionTwo = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                               strokes: [strokeTwo], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionTwo, on: doodleOne))
    }

    func testApplyUnremoveAction_invalidStrokeId_returnsNil() throws {
        doodleOne.strokes[4].isDeleted = true
        let stroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                       type: .stroke, entityId: doodleOne.strokes[5].strokeId,
                                       isDeleted: false)
        let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleOne.doodleId,
                                            strokes: [stroke], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(action, on: doodleOne))
    }

    func testApplyModifyAction_validAction_appliesAction() throws {
        let originalStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                               type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                               isDeleted: false)
        let newId = UUID()
        let newStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[5].stroke), 4,
                                          type: .stroke, entityId: newId, isDeleted: false)
        let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                            strokes: [originalStroke, newStroke], createdBy: "Testing")
        XCTAssertEqual(doodleOne.strokes.count, 10)
        XCTAssertEqual(doodleOne.drawing.dtStrokes.count, 10)
        let newDoodle = try XCTUnwrap(actionManager.applyAction(action, on: doodleOne))
        XCTAssertEqual(newDoodle.strokes.count, 10)
        XCTAssertEqual(newDoodle.drawing.dtStrokes.count, 10)
        XCTAssertEqual(newDoodle.strokes[4].stroke, newDoodle.strokes[5].stroke)
        XCTAssertEqual(newDoodle.strokes[4].strokeId, newId)
    }

    func testApplyModifyAction_invalidIndex_returnsNil() throws {
        let originalStrokeOne = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 10,
                                                  type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                                  isDeleted: false)
        let newStrokeOne = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[5].stroke), 10,
                                             type: .stroke, entityId: UUID(), isDeleted: false)
        let actionOne = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                               strokes: [originalStrokeOne, newStrokeOne], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionOne, on: doodleOne))

        let originalStrokeTwo = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), -1,
                                                  type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                                  isDeleted: false)
        let newStrokeTwo = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[5].stroke), -1,
                                             type: .stroke, entityId: UUID(), isDeleted: false)
        let actionTwo = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                               strokes: [originalStrokeTwo, newStrokeTwo], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(actionTwo, on: doodleOne))
    }

    func testApplyModifyAction_indexMismatch_returnsNil() throws {
        let originalStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                               type: .stroke, entityId: doodleOne.strokes[4].strokeId,
                                               isDeleted: false)
        let newStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[5].stroke), 5,
                                          type: .stroke, entityId: UUID(), isDeleted: false)
        let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                            strokes: [originalStroke, newStroke], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(action, on: doodleOne))
    }

    func testApplyModifyAction_invalidStrokeId_returnsNil() throws {
        let originalStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[4].stroke), 4,
                                               type: .stroke, entityId: doodleOne.strokes[5].strokeId,
                                               isDeleted: false)
        let newStroke = DTEntityIndexPair(try encoder.encode(doodleOne.strokes[5].stroke), 5,
                                          type: .stroke, entityId: UUID(), isDeleted: false)
        let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleOne.doodleId,
                                            strokes: [originalStroke, newStroke], createdBy: "Testing")
        XCTAssertNil(actionManager.applyAction(action, on: doodleOne))
    }

}
