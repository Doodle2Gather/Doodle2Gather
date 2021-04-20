import Fluent

struct AddPair: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("entity_type").read().flatMap { type in
            database.schema(PersistedDTEntityIndexPair.schema)
                .id()
                .field("type", type, .required)
                .field("entity_data", .data, .required)
                .field("index", .int, .required)
                .field("entity_id", .uuid, .required)
                .field("is_deleted", .bool, .required)
                .create()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTEntityIndexPair.schema).delete()
    }
}
