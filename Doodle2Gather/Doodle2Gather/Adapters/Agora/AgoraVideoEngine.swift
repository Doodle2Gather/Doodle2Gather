import AgoraRtcKit

/**
 Engine that interfaces with Agora.
 */
class AgoraVideoEngine: NSObject, VideoEngine {

    weak var delegate: VideoEngineDelegate?
    private var agoraKit: AgoraRtcEngineKit?
    private var callID: UInt = 0
    private var savedChannelName: String?
    private var savedToken: String?

    func initialize() {
        getAgoraEngine().setChannelProfile(.communication)
        getAgoraEngine().enableVideo()
        let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                           frameRate: .fps15,
                                                           bitrate: 400,
                                                           orientationMode: .fixedLandscape)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
    }

    func tearDown() {
        getAgoraEngine().leaveChannel(nil)
    }

    private func getAgoraTokenAndJoinChannel(channelName: String) {
        guard let user = DTAuth.user else {
            return
        }

        let url = URL(string: "\(ApiEndpoints.AgoraRtcTokenServer)?uid=\(callID)&channelName=\(channelName)")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                DTLogger.error("Error with fetching Agora token \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DTLogger.error("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data,
               let tokenResponse = try? JSONDecoder().decode(AgoraTokenAPIResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.getAgoraEngine()
                        .joinChannel(byUserAccount: user.uid,
                                     token: tokenResponse.key,
                                     channelId: channelName) { [weak self] _, uid, _ in
                            self?.callID = uid
                            self?.savedChannelName = channelName
                            self?.savedToken = tokenResponse.key
                        }
                }

            }
        })
        task.resume()
    }

    func joinChannel(channelName: String) {
        guard let user = DTAuth.user else {
            return
        }

        if channelName == savedChannelName {
            if let token = savedToken {
                self.getAgoraEngine().joinChannel(byUserAccount: user.uid, token: token, channelId: channelName)
            } else {
                DispatchQueue.main.async {
                    self.getAgoraTokenAndJoinChannel(channelName: channelName)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.getAgoraTokenAndJoinChannel(channelName: channelName)
            }
        }
    }

    func muteAudio() {
        getAgoraEngine().muteLocalAudioStream(true)
    }

    func unmuteAudio() {
        getAgoraEngine().muteLocalAudioStream(false)
    }

    func showVideo() {
        getAgoraEngine().enableLocalVideo(true)
    }

    func hideVideo() {
        getAgoraEngine().enableLocalVideo(false)
    }

    func setupLocalUserView(view: VideoCollectionViewCell) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = callID
        videoCanvas.view = view
        videoCanvas.renderMode = .fit
        getAgoraEngine().setupLocalVideo(videoCanvas)
    }

    func setupRemoteUserView(view: VideoCollectionViewCell, id remoteId: UInt) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = remoteId
        videoCanvas.view = view
        videoCanvas.renderMode = .fit
        getAgoraEngine().setupRemoteVideo(videoCanvas)
    }

    func getUserInfo(uid: UInt) -> String {
        if let userInfo = getAgoraEngine().getUserInfo(byUid: uid, withError: nil),
            let username = userInfo.userAccount {
            return username
        } else {
            return "Unknown"
        }
    }

    /**
     Returns the agora RTC engine instance (singleton).
     */
    private func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: ConferenceConstants.appID, delegate: self)
        }
        return agoraKit!
    }

}

// MARK: - AgoraRtcEngineDelegate

extension AgoraVideoEngine: AgoraRtcEngineDelegate {

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        callID = uid
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DTLogger.event("Joined call of uid: \(uid)")
        if let userInfo = getAgoraEngine().getUserInfo(byUid: uid, withError: nil),
            let username = userInfo.userAccount {
            delegate?.didJoinCall(id: uid, username: username)
        } else {
            delegate?.didJoinCall(id: uid, username: "Unknown")
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DTLogger.event("Left call of uid: \(uid)")
        if let userInfo = getAgoraEngine().getUserInfo(byUid: uid, withError: nil),
            let username = userInfo.userAccount {
            delegate?.didLeaveCall(id: uid, username: username)
        } else {
            delegate?.didLeaveCall(id: uid, username: "Unknown")
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didUpdatedUserInfo userInfo: AgoraUserInfo, withUid uid: UInt) {
        delegate?.didUpdateUserInfo(id: uid, username: userInfo.userAccount ?? "Unknown")
    }

}
