import Foundation
import Fluent
import DTSharedLibrary

class ActiveRoomController {
    var activeRooms: [UUID: [UUID: DTAdaptedDoodle]]

    let db: Database
    let logger: Logger

    init(db: Database) {
        activeRooms = [UUID: [UUID: DTAdaptedDoodle]]()
        self.db = db
        self.logger = Logger(label: "ActiveRoomController")
    }

    var activeRoomIds: Set<UUID> {
        Set(activeRooms.keys)
    }

    func isRoomActive(_ roomId: UUID) -> Bool {
        activeRoomIds.contains(roomId)
    }

    func process(_ action: DTAdaptedAction) -> DTAdaptedAction? {

        joinRoom(action.roomId) // create live copy of room

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

    func joinRoom(_ roomId: UUID) {
        if !isRoomActive(roomId) {
            activeRooms[roomId] = [UUID: DTAdaptedDoodle]()

            PersistedDTRoom.getAllDoodles(roomId, on: self.db).whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success(let doodles):
                    for doodle in doodles {
                        if let doodleId = try? doodle.requireID() {
                            self.activeRooms[roomId]?[doodleId] =
                                DTAdaptedDoodle(doodle: doodle)
                        }

                    }
                }
            }
        }
    }

    func addStroke(_ stroke: DTAdaptedStroke) -> [DTStrokeIndexPair]? {
        guard let index = activeRooms[stroke.roomId]?[stroke.doodleId]?.strokeCount else {
            return nil
        }
        activeRooms[stroke.roomId]?[stroke.doodleId]?.addStroke(stroke)
        return [DTStrokeIndexPair(stroke.stroke, index)]
    }

    func removeStrokes(_ strokes: [DTAdaptedStroke], _ pairs: [DTStrokeIndexPair]) -> [DTStrokeIndexPair]? {
        var returnPairs = [DTStrokeIndexPair]()
        for index in 0 ..< strokes.count {
            let stroke = strokes[index]
            let startingIndex = pairs[index].index
            guard let doodle = activeRooms[stroke.roomId]?[stroke.doodleId] else {
                return nil
            }
            let index = doodle.findFirstMatchIndex(for: stroke, startingFrom: startingIndex)
            guard let indexFound = index else {
                return nil
            }
            activeRooms[stroke.roomId]?[stroke.doodleId]?.removeStroke(at: indexFound)
            returnPairs.append(DTStrokeIndexPair(stroke.stroke, indexFound))
        }
        return returnPairs
    }

    func modifyStroke(original: DTAdaptedStroke, modified: DTAdaptedStroke,
                      pair: DTStrokeIndexPair) -> [DTStrokeIndexPair]? {
        let startingIndex = pair.index
        guard let doodle = activeRooms[original.roomId]?[original.doodleId] else {
            return nil
        }
        let index = doodle.findFirstMatchIndex(for: original, startingFrom: startingIndex)
        guard let indexFound = index else {
            return nil
        }
        activeRooms[original.roomId]?[original.doodleId]?.modifyStroke(at: indexFound, to: modified)
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
        getStroke(at: index) == stroke
    }
}
