import XCTest
import PencilKit
@testable import Doodle2Gather

class PKStrokePointTests: XCTestCase {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func testInit_withDtPoint_isCorrect() {
        let dtPoint = DTAdaptedTestHelper.createTestPoint()

        let point = PKStrokePoint(from: dtPoint)
        PencilKitTestHelper.XCTAssertApprox(point.location, dtPoint.location)
        PencilKitTestHelper.XCTAssertApprox(point.timeOffset, dtPoint.timeOffset)
        PencilKitTestHelper.XCTAssertApprox(point.size, dtPoint.size)
        PencilKitTestHelper.XCTAssertApprox(point.opacity, dtPoint.opacity)
        PencilKitTestHelper.XCTAssertApprox(point.force, dtPoint.force)
        PencilKitTestHelper.XCTAssertApprox(point.azimuth, dtPoint.azimuth)
        PencilKitTestHelper.XCTAssertApprox(point.altitude, dtPoint.altitude)
    }

    func testEquatableHashable_sameValues_isEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = pointOne

        XCTAssertEqual(pointOne, pointTwo)
        XCTAssertEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentLocation_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: CGPoint(x: 200_000, y: 200_000),
                                     timeOffset: pointOne.timeOffset,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity,
                                     force: pointOne.force,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentTimeOffset_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: 20,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity,
                                     force: pointOne.force,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentSize_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: pointOne.timeOffset,
                                     size: CGSize(width: 30, height: 30),
                                     opacity: pointOne.opacity,
                                     force: pointOne.force,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentOpacity_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: pointOne.timeOffset,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity > 0.5
                                        ? pointOne.opacity - 0.1
                                        : pointOne.opacity + 0.1,
                                     force: pointOne.force,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentForce_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: pointOne.timeOffset,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity,
                                     force: pointOne.force + 1,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentAzimuth_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: pointOne.timeOffset,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity,
                                     force: pointOne.force,
                                     azimuth: -pointOne.azimuth,
                                     altitude: pointOne.altitude)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEquatableHashable_differentAltitude_isNotEqual() {
        let pointOne = PencilKitTestHelper.createPoint()
        let pointTwo = PKStrokePoint(location: pointOne.location,
                                     timeOffset: pointOne.timeOffset,
                                     size: pointOne.size,
                                     opacity: pointOne.opacity,
                                     force: pointOne.force,
                                     azimuth: pointOne.azimuth,
                                     altitude: pointOne.altitude > CGFloat.pi / 4
                                        ? pointOne.altitude - 0.1
                                        : pointOne.altitude + 0.1)

        XCTAssertNotEqual(pointOne, pointTwo)
        XCTAssertNotEqual(pointOne.hashValue, pointTwo.hashValue)
    }

    func testEncodable_samePoint() throws {
        let originalPoint = PencilKitTestHelper.createPoint()
        let data = try encoder.encode(originalPoint)
        let decodedPoint = try decoder.decode(PKStrokePoint.self, from: data)
        XCTAssertEqual(originalPoint, decodedPoint)
    }

}
