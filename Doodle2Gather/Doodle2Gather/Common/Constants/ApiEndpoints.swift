enum ApiEndpoints {
    static let Login = "https://d2g.christopher.sg/login"
    static let AgoraRtcTokenServer = "https://d2g.christopher.sg/rtcToken"
    static let AgoraRtmTokenServer = "https://d2g.christopher.sg/rtmToken"
    static let Room = { (roomId: String) in "wss://d2g.christopher.sg/rooms/\(roomId)" }
    static let Api = "https://d2g.christopher.sg/api"

    // for testing only
    static let localRoom = "ws://localhost:8080/rooms/devRoom"
    static let localApi = "http://localhost:8080/api/"
}
