enum ApiEndpoints {
    static let Login = "https://d2g.christopher.sg/login"
    static let AgoraRtcTokenServer = "https://d2g.christopher.sg/rtcToken"
    static let AgoraRtmTokenServer = "https://d2g.christopher.sg/rtmToken"
    static let Room = { (roomId: String, userId: String) in "wss://d2g.christopher.sg/rooms/\(roomId)/\(userId)" }
    static let Api = "https://d2g.christopher.sg/api"
    static let WS = "wss://d2g.christopher.sg"

    // for testing only
    static let localRoom = { (roomId: String, userId: String) in "ws://172.31.11.134:8080/rooms/\(roomId)/\(userId)" }
    static let localApi = "http://172.31.11.134:8080/api/"
    static let localWS = "ws://172.31.11.134:8080"
}
