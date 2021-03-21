//
//  AgoraVideoEngine.swift
//  Doodle2Gather
//
//  Created by Christopher Goh on 21/3/21.
//

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

    func joinChannel(channelName: String) {
        getAgoraEngine().joinChannel(byToken: VideoConstants.tempToken,
                                     channelId: channelName,
                                     info: nil,
                                     uid: callID) { [weak self] _, uid, _ in
            self?.callID = uid
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
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: VideoConstants.appID, delegate: self)
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
        print("Joined call of uid: \(uid)")
        delegate?.didJoinCall(id: uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        delegate?.didLeaveCall(id: uid)
    }
}
