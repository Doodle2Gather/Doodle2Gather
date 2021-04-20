import Fluent
import Vapor
import DTSharedLibrary

/// Contains queries on`PersistedDTEntity`
extension PersistedDTEntity {

    // swiftlint:disable first_where
    static func getSingle(_ entity: Data, on db: Database) -> EventLoopFuture<PersistedDTEntity> {
        PersistedDTEntity.query(on: db)
            .filter(\.$entityData == entity)
            .first()
            .unwrap(or: DTError.modelNotFound(type: "PersistedDTEntity"))
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTEntity]> {
        PersistedDTEntity.query(on: db).all()
    }
}
