import UIKit

class ConferenceViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var videoButton: UIButton!
    @IBOutlet private var audioButton: UIButton!
    @IBOutlet private var chatButton: UIButton!

    var videoEngine: VideoEngine?
    var chatEngine: ChatEngine?
    var chatBox: ChatBoxDelegate?
    var remoteUserIDs: [UInt] = []
    lazy var chatList = [Message]()
    var isMuted = false
    var isVideoOff = false
    var isChatShown = false

    enum Segues {
        static let toChat = "toChat"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoEngine = AgoraVideoEngine()
        videoEngine?.delegate = self
        videoEngine?.initialize()
        videoEngine?.joinChannel(channelName: "testing")
        chatEngine = AgoraChatEngine()
        chatEngine?.initialize()
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

    // Passes data to the ChatViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toChat {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let vc = nav.topViewController as? ChatViewController else {
                return
            }
            chatEngine?.delegate = self
            vc.chatEngine = chatEngine
            self.chatBox = vc
            vc.deliverHandler = { message in
                self.chatList.append(message)
            }
            for msg in chatList {
                vc.messages.append(msg)
            }
        }
    }
}

// MARK: - VideoEngineDelegate

extension ConferenceViewController: VideoEngineDelegate {
    func didJoinCall(id: UInt) {
        remoteUserIDs.append(id)
        collectionView.reloadData()
    }

    func didLeaveCall(id: UInt) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == id }) {
            remoteUserIDs.remove(at: index)
            collectionView.reloadData()
        }
    }
}

// MARK: - ChatEngineDelegate
// Receives message from the server and delivers the message to the delegate

extension ConferenceViewController: ChatEngineDelegate {
    func deliverMessage(from user: String, message: String) {
        let msg = Message(sender: Sender(senderId: user, displayName: user),
                          messageId: UUID().uuidString,
                          sentDate: Date(), kind: .text(message))
        chatList.append(msg)
        chatBox?.onReceiveMessage(from: user, message: message)
    }
}

// MARK: - UICollectionViewDelegate

extension ConferenceViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource

extension ConferenceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        remoteUserIDs.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        guard let videoCell = cell as? VideoCollectionViewCell else {
            fatalError("Cell is not VideoCollectionViewCell")
        }
        if indexPath.row == 0 { // Put our local video first
            videoEngine?.setupLocalUserView(view: videoCell.getVideoView())
        } else {
            let remoteID = remoteUserIDs[indexPath.row - 1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.videoEngine?.setupRemoteUserView(view: videoCell.getVideoView(), id: remoteID)
            })
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConferenceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = collectionView.frame.width
            - collectionView.adjustedContentInset.left
            - collectionView.adjustedContentInset.right

        return CGSize(width: totalWidth, height: totalWidth * ConferenceConstants.aspectRatio)
    }
}
