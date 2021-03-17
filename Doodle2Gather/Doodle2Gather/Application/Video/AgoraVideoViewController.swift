//
//  AgoraVideoViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 17/3/21.
//

import UIKit
import AgoraRtcKit

class AgoraVideoViewController: UIViewController {
    var agoraKit: AgoraRtcEngineKit?

    @IBOutlet private var collectionView: UICollectionView!

    var inCall = false
    let tempToken: String? = nil // If you have a token, put it here.
    var callID: UInt = 0
    var channelName = "testing"
    var userName: String?
    var userID: UInt = 0
    var remoteUserIDs: [UInt] = []

    func joinChannel(channelName: String) {
        getAgoraEngine().joinChannel(byToken: tempToken,
                                     channelId: channelName,
                                     info: nil,
                                     uid: callID) { [weak self] _, uid, _ in
            self?.inCall = true
            self?.callID = uid
            self?.channelName = channelName
        }
    }

    func joinChannel() {
        if let name = userName {
            getAgoraEngine().joinChannel(byUserAccount: name,
                                         token: tempToken,
                                         channelId: channelName) { [weak self] _, uid, _ in
                self?.userID = uid
            }
        } else {
            getAgoraEngine().joinChannel(byToken: tempToken,
                                         channelId: channelName,
                                         info: nil,
                                         uid: userID) { [weak self] _, uid, _ in
                self?.userID = uid
            }
        }
    }

    private func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: VideoConstants.appID, delegate: self)
        }
        return agoraKit!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAgoraEngine().setChannelProfile(.communication)

        setUpVideo()
        joinChannel()
    }

    func setUpVideo() {
        getAgoraEngine().enableVideo()
        let configuration = AgoraVideoEncoderConfiguration(size:
                            AgoraVideoDimension640x360, frameRate: .fps15, bitrate: 400,
                            orientationMode: .fixedPortrait)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        remoteUserIDs.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)

        if indexPath.row == remoteUserIDs.count { // Put our local video last
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = callID
                videoCanvas.view = videoCell.videoView
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupLocalVideo(videoCanvas)
            }
        } else {
            let remoteID = remoteUserIDs[indexPath.row]
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = remoteID
                videoCanvas.view = videoCell.videoView
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupRemoteVideo(videoCanvas)
                print("Creating remote view of uid: \(remoteID)")
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numFeeds = remoteUserIDs.count + 1

        let totalWidth = collectionView.frame.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
        let totalHeight = collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom

        if numFeeds == 1 {
            return CGSize(width: totalWidth, height: totalHeight)
        } else if numFeeds == 2 {
            return CGSize(width: totalWidth, height: totalHeight / 2)
        } else {
            if indexPath.row == numFeeds {
                return CGSize(width: totalWidth, height: totalHeight / 2)
            } else {
                return CGSize(width: totalWidth / CGFloat(numFeeds - 1), height: totalHeight / 2)
            }
        }
    }
}

extension AgoraVideoViewController: AgoraRtcEngineDelegate {
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
