import Vapor

struct LoginRequest: Content {
    let username: String
    let password: String
}
