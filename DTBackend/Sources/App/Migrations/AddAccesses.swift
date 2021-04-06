import Fluent

struct AddAccesses: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTUserAccesses.schema)
            .id()
            .field("user_id", .string, .required,
                   .references(PersistedDTUser.schema, .id, onDelete: .cascade)
            )
            .field("room_id", .uuid, .required,
                   .references(PersistedDTRoom.schema, .id, onDelete: .cascade)
            )
            .unique(on: "user_id", "room_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTUserAccesses.schema).delete()
    }
}
