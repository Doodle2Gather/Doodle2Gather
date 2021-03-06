import XCTest
import PencilKit
@testable import Doodle2Gather
@testable import DTSharedLibrary

class DTPartialAdaptedActionTests: XCTestCase {

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func testInit_addActionWithEntityIndexPair_isCorrect() throws {
        let pairs = [try DTAdaptedTestHelper.createStrokeIndexPair()]
        let doodleId = UUID()
        let userString = "userString"

        let action = DTPartialAdaptedAction(type: .add, doodleId: doodleId, strokes: pairs, createdBy: userString)

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .add)
        XCTAssertEqual(action.entities, pairs)
    }

    func testInit_modifyActionWithEntityIndexPair_isCorrect() throws {
        let pairs = [try DTAdaptedTestHelper.createStrokeIndexPair(),
                     try DTAdaptedTestHelper.createStrokeIndexPair()]
        let doodleId = UUID()
        let userString = "userString"

        let action = DTPartialAdaptedAction(type: .modify, doodleId: doodleId, strokes: pairs, createdBy: userString)

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .modify)
        XCTAssertEqual(action.entities, pairs)
    }

    func testInit_removeActionWithEntityIndexPair_isCorrect() throws {
        var pairs = [DTEntityIndexPair]()
        let doodleId = UUID()
        let userString = "userString"

        for i in 0..<10 {
            pairs.append(try DTAdaptedTestHelper.createStrokeIndexPair(index: i, isDeleted: true))
        }

        let action = DTPartialAdaptedAction(type: .remove, doodleId: doodleId, strokes: pairs, createdBy: userString)

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .remove)
        XCTAssertEqual(action.entities, pairs)
    }

    func testInit_unremoveActionWithEntityIndexPair_isCorrect() throws {
        var pairs = [DTEntityIndexPair]()
        let doodleId = UUID()
        let userString = "userString"

        for i in 0..<10 {
            pairs.append(try DTAdaptedTestHelper.createStrokeIndexPair(index: i, isDeleted: false))
        }

        let action = DTPartialAdaptedAction(type: .unremove, doodleId: doodleId, strokes: pairs, createdBy: userString)

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .unremove)
        XCTAssertEqual(action.entities, pairs)
    }

    func testInit_addActionWithStrokeWrapper_isCorrect() throws {
        let pairs = [(DTAdaptedTestHelper.createStrokeWrapper(), 0)]
        let doodleId = UUID()
        let userString = "userString"

        let action = try XCTUnwrap(DTPartialAdaptedAction(type: .add,
                                                          doodleId: doodleId,
                                                          strokes: pairs, createdBy: userString))

        let entities = try pairs.map {
            DTEntityIndexPair(try encoder.encode($0.0.stroke), $0.1,
                              type: .stroke, entityId: $0.0.strokeId, isDeleted: $0.0.isDeleted)
        }

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .add)
        XCTAssertEqual(action.entities, entities)
    }

    func testInit_modifyActionWithStrokeWrapper_isCorrect() throws {
        let pairs = [(DTAdaptedTestHelper.createStrokeWrapper(), 0),
                     (DTAdaptedTestHelper.createStrokeWrapper(), 0)]
        let doodleId = UUID()
        let userString = "userString"

        let action = try XCTUnwrap(DTPartialAdaptedAction(type: .modify,
                                                          doodleId: doodleId,
                                                          strokes: pairs, createdBy: userString))

        let entities = try pairs.map {
            DTEntityIndexPair(try encoder.encode($0.0.stroke), $0.1,
                              type: .stroke, entityId: $0.0.strokeId, isDeleted: $0.0.isDeleted)
        }

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .modify)
        XCTAssertEqual(action.entities, entities)
    }

    func testInit_removeActionWithStrokeWrapper_isCorrect() throws {
        var pairs = [(DTStrokeWrapper, Int)]()
        let doodleId = UUID()
        let userString = "userString"

        for i in 0..<10 {
            pairs.append((DTAdaptedTestHelper.createStrokeWrapper(isDeleted: true), i))
        }

        let action = try XCTUnwrap(DTPartialAdaptedAction(type: .remove,
                                                          doodleId: doodleId,
                                                          strokes: pairs, createdBy: userString))

        let entities = try pairs.map {
            DTEntityIndexPair(try encoder.encode($0.0.stroke), $0.1,
                              type: .stroke, entityId: $0.0.strokeId, isDeleted: $0.0.isDeleted)
        }

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .remove)
        XCTAssertEqual(action.entities, entities)
    }

    func testInit_unremoveActionWithStrokeWrapper_isCorrect() throws {
        var pairs = [(DTStrokeWrapper, Int)]()
        let doodleId = UUID()
        let userString = "userString"

        for i in 0..<10 {
            pairs.append((DTAdaptedTestHelper.createStrokeWrapper(isDeleted: false), i))
        }

        let action = try XCTUnwrap(DTPartialAdaptedAction(type: .unremove,
                                                          doodleId: doodleId,
                                                          strokes: pairs, createdBy: userString))

        let entities = try pairs.map {
            DTEntityIndexPair(try encoder.encode($0.0.stroke), $0.1,
                              type: .stroke, entityId: $0.0.strokeId, isDeleted: $0.0.isDeleted)
        }

        XCTAssertEqual(action.createdBy, userString)
        XCTAssertEqual(action.doodleId, doodleId)
        XCTAssertEqual(action.type, .unremove)
        XCTAssertEqual(action.entities, entities)
    }

    func testInvert_withAddAction_shouldGiveRemoveAction() throws {
        let action = try DTAdaptedTestHelper.createPartialAddAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entities.count, 1)
        XCTAssertEqual(invertedAction.type, .remove)
        XCTAssert(invertedAction.entities[0].isDeleted)
        XCTAssertEqual(invertedAction.entities[0].entityId, action.entities[0].entityId)
        XCTAssertEqual(invertedAction.entities[0].index, action.entities[0].index)
        XCTAssertEqual(invertedAction.entities[0].type, action.entities[0].type)
        XCTAssertEqual(invertedAction.entities[0].entity, action.entities[0].entity)
    }

    func testInvert_withModifyAction_shouldGiveModifyAction() throws {
        let action = try DTAdaptedTestHelper.createPartialModifyAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
        XCTAssertEqual(invertedAction.entities.count, 2)
        XCTAssertEqual(invertedAction.type, .modify)
        XCTAssertEqual(invertedAction.entities[0], action.entities[1])
        XCTAssertEqual(invertedAction.entities[1], action.entities[0])
    }

    func testInvert_withRemoveAction_shouldGiveUnremoveAction() throws {
        let action = try DTAdaptedTestHelper.createPartialRemoveAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
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
        let action = try DTAdaptedTestHelper.createPartialUnremoveAction()
        let invertedAction = action.invert()

        XCTAssertEqual(invertedAction.createdBy, action.createdBy)
        XCTAssertEqual(invertedAction.doodleId, action.doodleId)
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
        let action = try DTAdaptedTestHelper.createPartialRemoveAction()
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
