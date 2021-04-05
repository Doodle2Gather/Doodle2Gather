import Fluent

struct AddRoom: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTRoom.schema)
            .id()
            .field("name", .string, .required)
            .field("invite_code", .string, .required)
            .field("created_by", .string, .required,
                   .references(PersistedDTUser.schema, .id, onDelete: .cascade)
            )
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTRoom.schema).delete()
    }
}
