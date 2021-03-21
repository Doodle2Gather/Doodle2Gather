//
//  VideoViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 17/3/21.
//

import UIKit

protocol VideoEngine {
    var delegate: VideoEngineDelegate? { get set }
    func initialize()
    func joinChannel(channelName: String)
    func muteAudio()
    func unmuteAudio()
    func showVideo()
    func hideVideo()
    func setupLocalUserView(view: VideoCollectionViewCell)
    func setupRemoteUserView(view: VideoCollectionViewCell, id: UInt)
}

protocol VideoEngineDelegate: AnyObject {
    func didJoinCall(id: UInt)
    func didLeaveCall(id: UInt)
}

class VideoViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var videoButton: UIButton!
    @IBOutlet private var audioButton: UIButton!

    var videoEngine: VideoEngine?
    var remoteUserIDs: [UInt] = []
    var isMuted = false
    var isVideoOff = false

    override func viewDidLoad() {
        super.viewDidLoad()
        videoEngine = AgoraVideoEngine()
        videoEngine?.delegate = self
        videoEngine?.initialize()
        videoEngine?.joinChannel(channelName: "testing")
    }

    @IBAction private func didToggleAudio(_ sender: Any) {
        if isMuted {
            videoEngine?.unmuteAudio()
            audioButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        } else {
            videoEngine?.muteAudio()
            audioButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        }
        isMuted.toggle()
    }

    @IBAction private func didToggleVideo(_ sender: Any) {
        if isVideoOff {
            videoEngine?.showVideo()
            videoButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        } else {
            videoEngine?.hideVideo()
            videoButton.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
        }
        isVideoOff.toggle()
    }

}

extension VideoViewController: VideoEngineDelegate {
    func didJoinCall(id: UInt) {
        remoteUserIDs.append(id)
        collectionView.reloadData()
    }

    func didLeaveCall(id: UInt) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == id }) {
            print(remoteUserIDs.count)
            remoteUserIDs.remove(at: index)
            collectionView.reloadData()
        }
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
        guard let videoCell = cell as? VideoCollectionViewCell else {
            fatalError("Cell is not VideoCollectionViewCell")
        }
        if indexPath.row == remoteUserIDs.count { // Put our local video last
            videoEngine?.setupLocalUserView(view: videoCell.getVideoView())
        } else {
            let remoteID = remoteUserIDs[indexPath.row]
            videoEngine?.setupRemoteUserView(view: videoCell.getVideoView(), id: remoteID)
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

        return CGSize(width: totalWidth, height: totalWidth * VideoConstants.aspectRatio)
    }
}
