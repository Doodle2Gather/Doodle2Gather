import Fluent
import Vapor
import DTSharedLibrary

/// Contains queries on `PersistedDTAction`
extension PersistedDTAction {

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db).all()
    }

    static func getLatest(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db)
            .sort(\.$createdAt, .descending)
            .range(..<5)
            .all()
    }
}
