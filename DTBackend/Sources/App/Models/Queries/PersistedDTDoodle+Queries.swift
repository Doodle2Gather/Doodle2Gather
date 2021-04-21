import Fluent
import Vapor
import DTSharedLibrary

/// Contains queries on `PersistedDTDoodle` that return adapted model
extension PersistedDTDoodle {

    /// Adds a doodle
    static func createDoodle(_ request: DTAdaptedDoodle.CreateRequest,
                             on db: Database) -> EventLoopFuture<DTAdaptedDoodle> {
        let newDoodle = request.makePersistedDoodle()
        return newDoodle.save(on: db)
            .flatMap { PersistedDTDoodle.getSingleById(newDoodle.id, on: db) }
            .flatMapThrowing(DTAdaptedDoodle.init)
    }

    /// Removes a doodle with the provided id
    static func removeDoodle(_ doodleId: UUID, on db: Database) -> EventLoopFuture<Void> {
        getSingleById(doodleId, on: db)
            .flatMap { $0.delete(on: db) }
    }
}

/// Contains queries on `PersistedDTDoodle` that return persisted model
extension PersistedDTDoodle {

    /// Gets a doodle by its doodle id
    static func getSingleById(_ id: PersistedDTDoodle.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTDoodle> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTDoodle"))
      }
      return PersistedDTDoodle.query(on: db)
        .filter(\.$id == id)
        .with(\.$entities)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTDoodle", id: id.uuidString))
    }

    /// Gets all strokes inside a doodle
    static func getAllStrokes(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTEntity]> {
        getSingleById(id, on: db)
            .map { $0.entities }
    }
}
