import Fluent

struct AddPair: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStrokeIndexPair.schema)
            .id()
            .field("stroke_data", .data, .required)
            .field("index", .int, .required)
            .field("stroke_id", .uuid, .required)
            .field("is_deleted", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStrokeIndexPair.schema).delete()
    }
}
