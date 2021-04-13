import Foundation
import Fluent
import DTSharedLibrary

class ActiveRoomController {

    let roomId: UUID

    var doodles: [UUID: DTAdaptedDoodle]

    let db: Database
    let logger: Logger

    var hasFetchedDoodles = false

    init(roomId: UUID, db: Database) {
        doodles = [UUID: DTAdaptedDoodle]()
        self.roomId = roomId
        self.db = db
        self.logger = Logger(label: "ActiveRoomController")
        joinRoom(roomId)
    }

    var doodleArray: [DTAdaptedDoodle] {
        Array(doodles.values)
    }

    func joinRoom(_ roomId: UUID) {
        PersistedDTRoom.getAllDoodles(roomId, on: self.db).whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success(let doodles):
                for doodle in doodles {
                    if let doodleId = try? doodle.requireID() {
                        self.doodles[doodleId] =
                            DTAdaptedDoodle(doodle: doodle)
                    }
                }
                self.hasFetchedDoodles = true
            }
        }
    }

    func process(_ action: DTAdaptedAction) -> DTAdaptedAction? {

//        joinRoom(action.roomId) // create live copy of room

        let strokes = action.makeStrokes()
        let strokeIndexPairs = action.strokes

        let returnPairs: [DTStrokeIndexPair]?

        switch action.type {
        case .add:
            if strokes.count != 1 {
                return nil
            }
            guard let strokeToAdd = strokes.first else {
                return nil
            }
            returnPairs = addStroke(strokeToAdd)

        case .remove:
            if strokes.isEmpty {
                return nil
            }
            returnPairs = removeStrokes(strokes, strokeIndexPairs)

        case .modify:
            if strokes.count != 2 {
                return nil
            }
            guard let originalStroke = strokes.first, let modifiedStroke = strokes.last,
                  let originalPair = strokeIndexPairs.first,
                  let modifiedPair = strokeIndexPairs.last,
                  originalPair.index == modifiedPair.index else {
                return nil
            }
            returnPairs = modifyStroke(original: originalStroke,
                                       modified: modifiedStroke,
                                       pair: originalPair)

        default:
            return nil
        }

        guard let pairs = returnPairs else {
            return nil
        }

        return action.getNewAction(with: pairs)
    }

    func addStroke(_ stroke: DTAdaptedStroke) -> [DTStrokeIndexPair]? {
        guard let index = doodles[stroke.doodleId]?.strokeCount else {
            return nil
        }
        doodles[stroke.doodleId]?.addStroke(stroke)
        self.logger.info("successfully modified")
        return [DTStrokeIndexPair(stroke.stroke, index)]
    }

    func removeStrokes(_ strokes: [DTAdaptedStroke], _ pairs: [DTStrokeIndexPair]) -> [DTStrokeIndexPair]? {
        var returnPairs = [DTStrokeIndexPair]()
        for index in 0 ..< strokes.count {
            let stroke = strokes[index]
            let startingIndex = pairs[index].index
            guard let doodle = doodles[stroke.doodleId] else {
                return nil
            }
            let index = doodle.findFirstMatchIndex(for: stroke, startingFrom: startingIndex)
            guard let indexFound = index else {
                let info = "cannot remove stroke with starting index \(startingIndex) expected:"
                    + "\(doodle.getStroke(at: startingIndex)) sent: \(stroke)"
                self.logger.info(info)
                self.logger.info("all strokes \(doodles[stroke.doodleId])")
                return nil
            }
            doodles[stroke.doodleId]?.removeStroke(at: indexFound)
            self.logger.info("successfully removed \(startingIndex)")
            self.logger.info("all strokes \(doodles[stroke.doodleId])")
            returnPairs.append(DTStrokeIndexPair(stroke.stroke, indexFound))
        }
        return returnPairs
    }

    func modifyStroke(original: DTAdaptedStroke, modified: DTAdaptedStroke,
                      pair: DTStrokeIndexPair) -> [DTStrokeIndexPair]? {
        let startingIndex = pair.index
        guard let doodle = doodles[original.doodleId] else {
            return nil
        }
        let index = doodle.findFirstMatchIndex(for: original, startingFrom: startingIndex)
        guard let indexFound = index else {
            let info = "cannot modify stroke with starting index "
                + "\(startingIndex) expected: \(doodle.getStroke(at: startingIndex)) sent: \(original)"
            self.logger.info(info)
            self.logger.info("all strokes \(doodles[original.doodleId])")
            return nil
        }
        doodles[original.doodleId]?.modifyStroke(at: indexFound, to: modified)
        self.logger.info("successfully modified \(startingIndex)")
        self.logger.info("all strokes \(doodles[original.doodleId])")
        return [DTStrokeIndexPair(original.stroke, indexFound),
                DTStrokeIndexPair(modified.stroke, indexFound)]
    }
}

extension DTAdaptedDoodle {

    /// Searching forward in the strokes array, to find the first matched stroke index
    /// `nil` is returned if no match is found
    func findFirstMatchIndex(for stroke: DTAdaptedStroke, startingFrom index: Int) -> Int? {
        for currIndex in (0...index).reversed() {
            if checkIfStrokeIsAtIndex(stroke, at: currIndex) {
                return currIndex
            }
        }
        return nil
    }

    func checkIfStrokeIsAtIndex(_ stroke: DTAdaptedStroke, at index: Int) -> Bool {
        if index >= strokeCount {
            return false
        }
        return getStroke(at: index) == stroke
    }
}
