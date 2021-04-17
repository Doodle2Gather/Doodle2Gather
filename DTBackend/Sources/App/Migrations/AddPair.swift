import Fluent

struct AddPair: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStrokeIndexPair.schema)
            .id()
            .field("stroke_data", .data, .required)
            .field("index", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStrokeIndexPair.schema).delete()
    }
}
