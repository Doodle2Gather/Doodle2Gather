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
            .field("is_owner", .bool, .required)
            .field("can_edit", .bool, .required)
            .field("can_video_conference", .bool, .required)
            .field("can_chat", .bool, .required)
            .unique(on: "user_id", "room_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTUserAccesses.schema).delete()
    }
}
