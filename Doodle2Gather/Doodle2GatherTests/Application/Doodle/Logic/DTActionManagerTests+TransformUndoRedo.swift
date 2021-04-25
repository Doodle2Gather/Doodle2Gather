import XCTest
@testable import Doodle2Gather
@testable import DTSharedLibrary

extension DTActionManagerTests {

    func testTransformAddAction_newStrokesAdded_transformsCorrectly() {

    }

    func testTransformAddAction_fewerStrokes_transformsCorrectly() {

    }

    func testTransformAddAction_noChangeInStrokes_sameAction() {

    }

    func testTransformRemoveAction_noChangeInStrokes_sameAction() {

    }

    func testTransformRemoveAction_someStrokesRemoved_transformsAction() {

    }

    func testTransformRemoveAction_allStrokesRemoved_returnsNil() {

    }

    func testTransformUnremoveAction_noChangeInStrokes_sameAction() {

    }

    func testTransformUnremoveAction_someStrokesUnremoved_transformsAction() {

    }

    func testTransformUnremoveAction_allStrokesUnremoved_returnsNil() {

    }

    func testTransformModifyAction_noChangeInStrokes_sameAction() {

    }

    func testTransformModifyAction_strokeModified_returnsNil() {

    }

    func testUndo_noActionAdded_returnsNil() {

    }

    func testUndo_oneActionAdded_returnsInvertedAction() {

    }

    func testUndo_twoActionsAdded_returnsInvertedLastAction() {

    }

    func testRedo_noActionUndone_returnsNil() {

    }

    func testRedo_oneActionUndone_returnsInvertedAction() {

    }

    func testRedo_twoActionsUndone_returnsInvertedLastAction() {

    }

    func testRedo_actionUndoneThenNewActionAdded_returnsNil() {

    }

    func testCanUndo_noActionAdded_isFalse() {

    }

    func testCanUndo_actionAdded_isTrue() {

    }

    func testCanUndo_actionAddedThenUndone_isFalse() {

    }

    func testCanRedo_noActionUndone_isFalse() {

    }

    func testCanRedo_actionUndone_isTrue() {

    }

    func testCanRedo_actionUndoneThenRedone_isFalse() {

    }

    func testCanRedo_actionUndoneThenNewActionAdded_isFalse() {

    }

}
