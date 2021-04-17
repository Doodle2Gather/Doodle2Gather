import AgoraRtcKit

/**
 Engine that interfaces with Agora.
 */
class AgoraVideoEngine: NSObject, VideoEngine {

    weak var delegate: VideoEngineDelegate?
    private var agoraKit: AgoraRtcEngineKit?
    private var callID: UInt = 0

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
                    }
                }

            }
        })
        task.resume()
    }

    func joinChannel(channelName: String) {
        DispatchQueue.main.async {
            self.getAgoraTokenAndJoinChannel(channelName: channelName)
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
        delegate?.didJoinCall(id: uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DTLogger.event("Left call of uid: \(uid)")
        delegate?.didLeaveCall(id: uid)
    }

}
