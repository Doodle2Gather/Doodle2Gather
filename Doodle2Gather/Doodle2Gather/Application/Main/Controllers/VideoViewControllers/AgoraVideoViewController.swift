//
//  AgoraVideoViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 17/3/21.
//

import UIKit
import AgoraRtcKit

class AgoraVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var hangUpButton: UIButton!

    let appID = "4bc7d320fa674c4bbba8abbfddbfd4d3"
    var agoraKit: AgoraRtcEngineKit?
    let tempToken: String? = """
        0064bc7d320fa674c4bbba8abbfddbfd4d3IACknSUGNeRQhVEyYYVi
        1nW9calQZi7iQLIMHyPo3ri2NwZa8+gAAAAAEAAEa9nriXpJYAEAAQCIeklg
    """
    var userID: UInt = 0
    var userName: String?
    var channelName = "testing"
    var remoteUserIDs: [UInt] = []

    var muted = false {
        didSet {
            if muted {
                muteButton.setTitle("Unmute", for: .normal)
            } else {
                muteButton.setTitle("Mute", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpVideo()
        joinChannel()
    }

    func setUpVideo() {
        getAgoraEngine().enableVideo()

        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = userID
        videoCanvas.view = localVideoView
        videoCanvas.renderMode = .fit
        getAgoraEngine().setupLocalVideo(videoCanvas)
    }

    func joinChannel() {
        localVideoView.isHidden = false

        if let name = userName {
            getAgoraEngine().joinChannel(byUserAccount: name,
                                         token: tempToken,
                                         channelId: channelName) { [weak self] _, uid, _ in
                self?.userID = uid
            }
        } else {
            getAgoraEngine().joinChannel(byToken: tempToken,
                                         channelId: channelName,
                                         info: nil, uid: userID) { [weak self] _, uid, _ in
                self?.userID = uid
            }
        }
    }

    private func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appID, delegate: self)
        }

        return agoraKit!
    }

    @IBAction private func didToggleMute(_ sender: Any) {
        if muted {
            getAgoraEngine().muteLocalAudioStream(false)
        } else {
            getAgoraEngine().muteLocalAudioStream(true)
        }
        muted.toggle()
    }

    @IBAction private func didTapHangUp(_ sender: Any) {
        leaveChannel()
    }

    func leaveChannel() {
        getAgoraEngine().leaveChannel(nil)
        localVideoView.isHidden = true
        remoteUserIDs.removeAll()
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        remoteUserIDs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)

        let remoteID = remoteUserIDs[indexPath.row]
        if let videoCell = cell as? VideoCollectionViewCell {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = remoteID
            videoCanvas.view = videoCell.videoView
            videoCanvas.renderMode = .fit
            getAgoraEngine().setupRemoteVideo(videoCanvas)

            if let userInfo = getAgoraEngine().getUserInfo(byUid: remoteID, withError: nil),
                let username = userInfo.userAccount {
                videoCell.nameplateView.isHidden = false
                videoCell.usernameLabel.text = username
            } else {
                videoCell.nameplateView.isHidden = true
            }
        }

        return cell
    }
}

extension AgoraVideoViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        remoteUserIDs.append(uid)
        collectionView.reloadData()
    }

    // Sometimes, user info isn't immediately available when a remote user joins
    // if we get it later, reload their nameplate.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didUpdatedUserInfo userInfo: AgoraUserInfo,
                   withUid uid: UInt) {
        if let index = remoteUserIDs.first(where: { $0 == uid }) {
            collectionView.reloadItems(at: [IndexPath(item: Int(index), section: 0)])
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt,
                   reason: AgoraUserOfflineReason) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == uid }) {
            remoteUserIDs.remove(at: index)
            collectionView.reloadData()
        }
    }
}
