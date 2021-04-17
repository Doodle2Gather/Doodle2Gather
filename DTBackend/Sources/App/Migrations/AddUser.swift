import Fluent

struct AddUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTUser.schema)
            .field("id", .string, .identifier(auto: false))
            .field("display_name", .string, .required)
            .field("email", .string, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PersistedDTAction.schema).delete()
    }
}
