//
//  File.swift
//  
//
//  Created by Christopher Goh on 21/3/21.
//

import Fluent
import Vapor

struct LoginRequest: Content {
    let username: String
    let password: String
}
