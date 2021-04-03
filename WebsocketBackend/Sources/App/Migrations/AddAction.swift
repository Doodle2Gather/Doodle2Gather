import Fluent

struct AddAction: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTAction.schema)
            .id()
            .field("strokes_added", .array(of: .data), .required)
            .field("strokes_removed", .array(of: .data), .required)
            .field("room_id", .uuid, .required)
            .field("created_by", .uuid, .required)
            .field("created_at", .date)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTAction.schema).delete()
    }
}
