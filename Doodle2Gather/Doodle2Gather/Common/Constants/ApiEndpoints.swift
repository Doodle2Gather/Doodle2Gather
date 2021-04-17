enum ApiEndpoints {
    static let Login = "https://d2g.christopher.sg/login"
    static let AgoraRtcTokenServer = "https://d2g.christopher.sg/rtcToken"
    static let AgoraRtmTokenServer = "https://d2g.christopher.sg/rtmToken"
    static let Room = { (roomId: String, userId: String) in "wss://d2g.christopher.sg/rooms/\(roomId)/\(userId)" }
    static let Api = "https://d2g.christopher.sg/api"

    // for testing only
    static let localRoom = { (roomId: String, userId: String) in "ws://localhost:8080/rooms/\(roomId)/\(userId)" }
    static let localApi = "http://localhost:8080/api/"
}
