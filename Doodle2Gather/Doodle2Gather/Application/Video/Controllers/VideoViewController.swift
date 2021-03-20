//
//  VideoViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 17/3/21.
//

import UIKit
import AgoraRtcKit

class VideoViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private weak var videoButton: UIButton!
    @IBOutlet private weak var audioButton: UIButton!

    var agoraKit: AgoraRtcEngineKit?
    var remoteUserIDs: [UInt] = []
    var inCall = false
    var callID: UInt = 0
    var channelName = "testing"
    var isMuted = false
    var isVideoOff = false

    override func viewDidLoad() {
        super.viewDidLoad()

        getAgoraEngine().setChannelProfile(.communication)
        setUpVideo()
        joinChannel(channelName: channelName)
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

    func setUpVideo() {
        getAgoraEngine().enableVideo()
        let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                           frameRate: .fps15,
                                                           bitrate: 400,
                                                           orientationMode: .fixedLandscape)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
    }

    func joinChannel() {
        getAgoraEngine().joinChannel(byToken: VideoConstants.tempToken,
                                     channelId: channelName,
                                     info: nil,
                                     uid: callID) { [weak self] _, uid, _ in
            self?.callID = uid
        }
    }

    func joinChannel(channelName: String) {
        getAgoraEngine().joinChannel(byToken: VideoConstants.tempToken,
                                     channelId: channelName,
                                     info: nil,
                                     uid: callID) { [weak self] _, uid, _ in
            self?.inCall = true
            self?.callID = uid
            self?.channelName = channelName
        }
    }

    @IBAction private func didToggleAudio(_ sender: Any) {
        if isMuted {
            getAgoraEngine().muteLocalAudioStream(false)
            audioButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        } else {
            getAgoraEngine().muteLocalAudioStream(true)
            audioButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        }
        isMuted.toggle()
    }

    @IBAction private func didToggleVideo(_ sender: Any) {
        if isVideoOff {
            getAgoraEngine().enableLocalVideo(true)
            videoButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        } else {
            getAgoraEngine().enableLocalVideo(false)
            videoButton.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
        }
        isVideoOff.toggle()
    }
}

// MARK: - UICollectionViewDelegate
extension VideoViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource
extension VideoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        remoteUserIDs.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)

        if indexPath.row == remoteUserIDs.count { // Put our local video last
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = callID
                videoCanvas.view = videoCell.getVideoView()
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupLocalVideo(videoCanvas)
            }
        } else {
            let remoteID = remoteUserIDs[indexPath.row]
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = remoteID
                videoCanvas.view = videoCell.getVideoView()
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupRemoteVideo(videoCanvas)
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension VideoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = collectionView.frame.width
            - collectionView.adjustedContentInset.left
            - collectionView.adjustedContentInset.right

        return CGSize(width: totalWidth, height: totalWidth * 9 / 16)
    }
}

// MARK: - AgoraRtcEngineDelegate
extension VideoViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        callID = uid
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("Joined call of uid: \(uid)")
        remoteUserIDs.append(uid)
        collectionView.reloadData()
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == uid }) {
            remoteUserIDs.remove(at: index)
            collectionView.reloadData()
        }
    }
}
