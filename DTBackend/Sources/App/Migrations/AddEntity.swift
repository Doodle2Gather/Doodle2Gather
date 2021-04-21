import Fluent

struct AddEntity: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("entity_type")
            .case("stroke")
            .create()
            .flatMap { _ in
                database.enum("entity_type").read().flatMap { type in
                    database.schema(PersistedDTEntity.schema)
                        .id()
                        .field("type", type, .required)
                        .field("room_id", .uuid, .required)
                        .field("doodle_id",
                               .uuid, .required, .references(PersistedDTDoodle.schema, .id, onDelete: .cascade))
                        .field("entity_data", .data, .required)
                        .field("entity_id", .uuid, .required)
                        .field("is_deleted", .bool, .required)
                        .field("created_by", .uuid, .required)
                        .create()
                }
            }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.enum("entity_type").delete().flatMap {
            database.schema(PersistedDTEntity.schema).delete()
        }
    }
}
