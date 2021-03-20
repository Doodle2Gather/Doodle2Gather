//
//  WebSocketTypes.swift
//  Doodle2Gather
//
//  Created by eksinyue on 20/3/21.
//

import Foundation

enum DoodleActionMessageType: String, Codable {
    // Client to server types
    case newAction
    // Server to client types
    case handshake, response
}

struct DoodleActionMessageData: Codable {
  let type: DoodleActionMessageType
  let id: UUID
}

struct DoodleActionHandShake: Codable {
  var type = DoodleActionMessageType.handshake
  let id: UUID
}

struct NewDoodleActionMessage: Codable {
    var type: DoodleActionMessageType = .newAction
    let id: UUID
    let content: String
}

struct NewDoodleActionResponse: Codable, Comparable {
  var type = DoodleActionMessageType.response
  let success: Bool
  let message: String
  let id: UUID?
  let content: String
  let createdAt: Date?
    
    static func < (lhs: NewDoodleActionResponse, rhs: NewDoodleActionResponse) -> Bool {
      guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else { return false }
      return lhsDate < rhsDate
    }
    
    static func == (lhs: NewDoodleActionResponse, rhs: NewDoodleActionResponse) -> Bool {
      lhs.id == rhs.id
    }
}
