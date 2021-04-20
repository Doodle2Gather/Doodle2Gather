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

    func addDoodle(_ doodle: DTAdaptedDoodle) {
        guard let doodleId = doodle.doodleId else {
            return
        }
        self.doodles[doodleId] = doodle
    }

    func removeDoodle(_ doodleId: UUID) {
        self.doodles[doodleId] = nil
    }

    func process(_ action: DTAdaptedAction) -> DTAdaptedAction? {
        switch action.entityType {
        case .stroke:
            let strokes = action.makeStrokes()
            let pairs = action.getStrokeIndexPairs()
            self.logger.info("Applying stroke action")
            return applyAction(action: action, entities: strokes, pairs: pairs)
        case .text:
            let text = action.makeText()
            let pairs = action.getTextIndexPairs()
            self.logger.info("Applying text action")
            return applyAction(action: action, entities: text, pairs: pairs)
        default:
            self.logger.error("Action is missing type")
            return nil
        }
    }

    func applyAction<T: DTAdaptedEntityProtocol>(
        action: DTAdaptedAction, entities: [T], pairs: [DTEntityIndexPair]) -> DTAdaptedAction? {
        let returnPairs: [DTEntityIndexPair]?

        switch action.type {
        case .add:
            guard entities.count == 1, let toAdd = entities.first else {
                self.logger.error("Add action has incorrect number of entities")
                return nil
            }

            returnPairs = addEntity(toAdd)
        case .remove:
            if entities.isEmpty {
                self.logger.error("Remove action has incorrect number of entities")
                return nil
            }
            returnPairs = removeEntities(entities, pairs)

        case .unremove:
            if entities.isEmpty {
                self.logger.error("Unremove action has incorrect number of entities")
                return nil
            }
            returnPairs = unremoveEntities(entities, pairs)

        case .modify:
            if entities.count != 2 {
                self.logger.error("Modify action has incorrect number of entities")
                return nil
            }
            guard let originalStroke = entities.first, let modifiedStroke = entities.last,
                  let originalPair = pairs.first,
                  let modifiedPair = pairs.last,
                  originalPair.index == modifiedPair.index else {
                return nil
            }
            returnPairs = modifyEntity(original: originalStroke,
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

    func addEntity<T: DTAdaptedEntityProtocol>(_ entity: T) -> [DTEntityIndexPair]? {
        guard var doodle = doodles[entity.doodleId] else {
            self.logger.error("Trying to add entity to non-existent doodle")
            return nil
        }

        var index: Int
        switch entity.type {
        case .stroke:
            index = doodle.strokes.count
        case .text:
            index = doodle.text.count
        }

        doodle.addEntity(entity)
        doodles[entity.doodleId] = doodle
        self.logger.info("successfully added")
        return [entity.makeEntityIndexPair(index: index)]
    }

    func removeEntities<T: DTAdaptedEntityProtocol>(
        _ entities: [T], _ pairs: [DTEntityIndexPair]) -> [DTEntityIndexPair]? {
        guard let firstEntity = entities.first, var doodle = doodles[firstEntity.doodleId] else {
            self.logger.error("Trying to remove entity to non-existent doodle")
            return nil
        }

        var entitySet: [T]?
        switch firstEntity.type {
        case .stroke:
            entitySet = doodle.strokes as? [T]
        case .text:
            entitySet = doodle.text as? [T]
        }
        guard let entitiesInDoodle = entitySet else {
            return nil
        }

        var returnPairs = [DTEntityIndexPair]()
        for ind in 0 ..< entities.count {
            let entity = entities[ind]
            let index = pairs[ind].index
            if entitiesInDoodle[index] != entity {
                self.logger.error("Client and server doodle out of sync at index \(index)")
                return nil
            }
            doodle.removeEntity(entity, at: index)
            returnPairs.append(
                entity.makeEntityIndexPair(index: index)
            )
        }

        doodles[firstEntity.doodleId] = doodle
        self.logger.info("successfully removed")
        return returnPairs
    }

    func unremoveEntities<T: DTAdaptedEntityProtocol>(
        _ entities: [T], _ pairs: [DTEntityIndexPair]) -> [DTEntityIndexPair]? {
        guard let firstEntity = entities.first, var doodle = doodles[firstEntity.doodleId] else {
            self.logger.error("Trying to unremove entity from non-existent doodle")
            return nil
        }

        var entitySet: [T]?
        switch firstEntity.type {
        case .stroke:
            entitySet = doodle.strokes as? [T]
        case .text:
            entitySet = doodle.text as? [T]
        }
        guard let entitiesInDoodle = entitySet else {
            return nil
        }

        var returnPairs = [DTEntityIndexPair]()
        for ind in 0 ..< entities.count {
            let entity = entities[ind]
            let index = pairs[ind].index
            if entitiesInDoodle[index] != entity {
                self.logger.error("Client and server doodle out of sync at index \(index)")
                self.logger.error("Client: \(entity) Server: \(entities[index])")
                return nil
            }
            doodle.unremoveEntity(entity, at: index)
            returnPairs.append(
                entity.makeEntityIndexPair(index: index)
            )
        }

        doodles[firstEntity.doodleId] = doodle
        self.logger.info("successfully unremoved")
        return returnPairs
    }

    func modifyEntity<T: DTAdaptedEntityProtocol>(
        original: T, modified: T, pair: DTEntityIndexPair
    ) -> [DTEntityIndexPair]? {
        guard var doodle = doodles[original.doodleId] else {
            self.logger.error("Trying to modify entity in non-existent doodle")
            return nil
        }

        var entitySet: [T]?
        switch original.type {
        case .stroke:
            entitySet = doodle.strokes as? [T]
        case .text:
            entitySet = doodle.text as? [T]
        }
        guard let entities = entitySet else {
            return nil
        }

        let index = pair.index
        if entities[index] != original {
            self.logger.error("Client and server doodle out of sync at index \(index)")
            return nil
        }
        doodle.modifyEntity(at: index, to: modified)

        doodles[original.doodleId] = doodle
        self.logger.info("successfully modified")
        return [original.makeEntityIndexPair(index: index),
                modified.makeEntityIndexPair(index: index)]
    }
}
