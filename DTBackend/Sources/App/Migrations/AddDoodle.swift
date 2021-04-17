import Fluent

struct AddDoodle: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTDoodle.schema)
            .id()
            .field("room_id", .uuid, .required, .references(PersistedDTRoom.schema, .id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTDoodle.schema).delete()
    }
}
