//
//  AddAction.swift
//  
//
//  Created by eksinyue on 17/3/21.
//

import Fluent

struct AddAction: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(DoodleAction.schema)
            .id()
            .field("content", .string, .required)
            //      .field("answered", .bool, .required, .sql(.default(false)))
            .field("created_by", .uuid, .required)
            .field("created_at", .date)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(DoodleAction.schema).delete()
    }
}

