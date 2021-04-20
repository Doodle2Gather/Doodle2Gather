import Fluent

struct AddAction: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTAction.schema)
            .id()
            .field("action_type", .string, .required)
            .field("room_id", .uuid, .required)
            .field("doodle_id", .uuid, .required, .references(PersistedDTDoodle.schema, .id, onDelete: .cascade))
            .field("entities", .array(of: .custom(PersistedDTEntityIndexPair.self)), .required)
            .field("created_by", .uuid, .required)
            .field("created_at", .date)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTAction.schema).delete()
    }
}
