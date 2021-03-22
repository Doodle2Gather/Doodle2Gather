import Fluent

struct AddAction: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DoodleAction.schema)
            .id()
            .field("strokesAdded", .string, .required)
            .field("strokesRemoved", .string, .required)
            .field("created_by", .uuid, .required)
            .field("created_at", .date)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DoodleAction.schema).delete()
    }
}
