import Foundation

enum QnAMessageType: String, Codable {
  // Client to server types
  case newQuestion
  // Server to client types
  case questionResponse, handshake, questionAnswer
}

struct NewQuestionResponse: Codable {
  var type = QnAMessageType.questionResponse
  let success: Bool
  let message: String
  let id: UUID?
  let answered: Bool
  let content: String
  let createdAt: Date?
}

struct QuestionAnsweredMessage: Codable {
  var type = QnAMessageType.questionAnswer
  let questionId: UUID
}

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
  let content: String
}

struct NewDoodleActionResponse: Codable {
  var type = DoodleActionMessageType.response
  let success: Bool
  let message: String
  let id: UUID?
  let content: String
  let createdAt: Date?
}
