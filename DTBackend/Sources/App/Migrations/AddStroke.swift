import Fluent

struct AddStroke: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStroke.schema)
            .id()
            .field("room_id", .uuid, .required)
            .field("doodle_id", .uuid, .required, .references(PersistedDTDoodle.schema, .id, onDelete: .cascade))
            .field("stroke_data", .data, .required)
            .field("created_by", .uuid, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTStroke.schema).delete()
    }
}
