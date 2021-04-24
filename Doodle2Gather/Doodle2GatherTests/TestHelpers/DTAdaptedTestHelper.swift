import XCTest
import PencilKit
@testable import DTSharedLibrary
@testable import Doodle2Gather

struct DTAdaptedTestHelper {

    static let encoder = JSONEncoder()

    static func createStrokeIndexPair(numberOfPoints: Int = 10, index: Int = 0,
                                      isDeleted: Bool = false) throws -> DTEntityIndexPair {
        let stroke = PencilKitTestHelper.createStroke(numberOfPoints: numberOfPoints)
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

    static func createStrokeWrapper(isDeleted: Bool = false) -> DTStrokeWrapper {
        let stroke = PencilKitTestHelper.createStroke()
        return DTStrokeWrapper(stroke: stroke, strokeId: UUID(), createdBy: "userString", isDeleted: isDeleted)
    }

    static func createDoodleWrapper(numberOfStrokes: Int = 10) -> DTDoodleWrapper {
        var doodle = DTDoodleWrapper()
        for _ in 0..<numberOfStrokes {
            doodle.strokes.append(createStrokeWrapper())
        }
        return doodle
    }

    static func createAdaptedStroke(numberOfPoints: Int = 10, index: Int = 0,
                                    roomId: UUID = UUID(), doodleId: UUID = UUID(),
                                    isDeleted: Bool = false) throws -> DTAdaptedStroke {
        let stroke = try createStrokeIndexPair(numberOfPoints: numberOfPoints, index: index, isDeleted: isDeleted)
        return DTAdaptedStroke(stroke, roomId: roomId, doodleId: doodleId, createdBy: "userString")
    }

    static func createAdaptedDoodle(numberOfStrokes: Int = 10, roomId: UUID = UUID(),
                                    doodleId: UUID = UUID()) throws -> DTAdaptedDoodle {
        var strokes = [DTAdaptedStroke]()
        for i in 0..<numberOfStrokes {
            strokes.append(try createAdaptedStroke(numberOfPoints: 10, index: i, roomId: roomId,
                                                   doodleId: doodleId, isDeleted: false))
        }

        return DTAdaptedDoodle(roomId: roomId, createdAt: Date(), doodleId: doodleId, strokes: strokes)
    }

    static func createTestPoint() -> TestPoint {
        TestPoint(location: CGPoint(x: CGFloat.random(in: 0...500), y: CGFloat.random(in: 0...500)),
                  timeOffset: Double.random(in: 0...2),
                  size: CGSize(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15)),
                  opacity: CGFloat.random(in: 0.1...1),
                  force: CGFloat.random(in: 0...1),
                  azimuth: CGFloat.random(in: -CGFloat.pi...CGFloat.pi),
                  altitude: CGFloat.random(in: 0...(CGFloat.pi / 2)))
    }

    static func createTestStroke(numberOfPoints: Int = 10) -> TestStroke {
        var points = [TestPoint]()
        for _ in 0..<numberOfPoints {
            points.append(createTestPoint())
        }
        return TestStroke(color: UIColor(displayP3Red: CGFloat.random(in: 0...1),
                                         green: CGFloat.random(in: 0...1),
                                         blue: CGFloat.random(in: 0...1),
                                         alpha: CGFloat.random(in: 0...1)),
                        tool: [DTCodableTool.pen, DTCodableTool.highlighter, DTCodableTool.pencil].randomElement()!,
                        points: points,
                        transform: DoodleConstants.defaultTransform,
                        mask: nil)
    }

    static func createTestDoodle(numberOfStrokes: Int = 10) -> TestDoodle {
        var strokes = [TestStroke]()
        for _ in 0..<numberOfStrokes {
            strokes.append(createTestStroke())
        }
        return TestDoodle(strokes: strokes)
    }

}
