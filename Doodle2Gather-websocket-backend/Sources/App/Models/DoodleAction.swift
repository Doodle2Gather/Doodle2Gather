//
//  DoodleAction.swift
//  
//
//  Created by eksinyue on 17/3/21.
//

import Fluent
import Vapor

final class DoodleAction: Model, Content {
    static let schema = "actions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "created_by")
    var createdBy: UUID
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, content: String, createdBy: UUID) {
        self.id = id
        self.content = content
        self.createdBy = createdBy
    }
}
