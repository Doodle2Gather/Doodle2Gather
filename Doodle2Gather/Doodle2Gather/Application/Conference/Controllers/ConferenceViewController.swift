import UIKit

class ConferenceViewController: UIViewController {

    // UI Elements
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var timerButton: UIButton!
    @IBOutlet private var voteButton: UIButton!
    @IBOutlet private var startStopButton: UIButton!
    @IBOutlet private var presentButton: UIButton!
    @IBOutlet private var participantsButton: UIButton!
    @IBOutlet private var videoButton: UIButton!
    @IBOutlet private var audioButton: UIButton!
    @IBOutlet private var chatButton: UIButton!
    @IBOutlet private var pageIndicator: UIView!
    @IBOutlet private var resizeButton: UIButton!
    @IBOutlet private var topControlView: UIView!

    var videoEngine: VideoEngine?
    var chatEngine: ChatEngine?
    var chatBox: ChatBoxDelegate?
    var remoteUserIDs: [UInt] = []
    lazy var chatList = [Message]()
    var isMuted = true
    var isVideoOff = true
    var isChatShown = false
    private var videoOverlays = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        videoEngine = AgoraVideoEngine()
        videoEngine?.delegate = self
        videoEngine?.initialize()
        videoEngine?.joinChannel(channelName: "testing")
        chatEngine = AgoraChatEngine()
        chatEngine?.initialize()
        chatEngine?.joinChannel(channelName: "testing")
        pageIndicator.isHidden = false

        videoEngine?.muteAudio()
        videoEngine?.hideVideo()
    }

    @IBAction private func audioButtonDidTap(_ sender: Any) {
        if isMuted {
            videoEngine?.unmuteAudio()
        } else {
            videoEngine?.muteAudio()
        }
        audioButton.isSelected = isMuted
        isMuted.toggle()
    }

    @IBAction private func videoButtonDidTap(_ sender: Any) {
        if isVideoOff {
            videoEngine?.showVideo()
            if !videoOverlays.isEmpty {
                videoOverlays[0].removeFromSuperview()
            }
        } else {
            videoEngine?.hideVideo()
            guard let cellView = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) else {
                return
            }
            if videoOverlays.isEmpty {
                let overlay = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: cellView.frame.size.width,
                                                   height: cellView.frame.size.height))
                overlay.backgroundColor = UIColor(named: "Black")
                videoOverlays.append(overlay)
                cellView.addSubview(overlay)
            } else {
                cellView.addSubview(videoOverlays[0])
            }
        }
        videoButton.isSelected = isVideoOff
        isVideoOff.toggle()
    }

    @IBAction private func bottomMinimizeButtonDidTap(_ sender: UIButton) {
        timerButton.isHidden.toggle()
        voteButton.isHidden.toggle()
        chatButton.isHidden.toggle()
        startStopButton.isHidden.toggle()
        audioButton.isHidden.toggle()
        videoButton.isHidden.toggle()
        presentButton.isHidden.toggle()
        participantsButton.isHidden.toggle()
        sender.isSelected.toggle()
    }

    @IBAction private func didTapResizeButton(_ sender: UIButton) {
        collectionView.isHidden.toggle()
        if collectionView.isHidden {
            pageIndicator.frame = topControlView.frame.offsetBy(dx: 0, dy: 50)
        } else {
            if remoteUserIDs.count <= 2 {
                pageIndicator.frame = topControlView.frame.offsetBy(dx: 0, dy: 50 + CGFloat(remoteUserIDs.count + 1) * 122.5)
            } else {
                pageIndicator.frame = topControlView.frame.offsetBy(dx: 0, dy: 50 + 3 * 122.5)
            }
        }
    }

    // Passes data to the ChatViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toChat {
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
        pageIndicator.isHidden = false

        if remoteUserIDs.count <= 2 {
            pageIndicator.frame = topControlView.frame.offsetBy(dx: 0,
                                                                dy: 50 + CGFloat(remoteUserIDs.count + 1) * 122.5)
        } else {
            pageIndicator.frame = topControlView.frame.offsetBy(dx: 0, dy: 50 + 3 * 122.5)
        }
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
        let prefix = message.prefix(while: { "0"..."9" ~= $0 })
        let numericPrefix = String(prefix)
        let prefixLength = prefix.count + 1
        guard let nameCount = Int(numericPrefix) else {
            DTLogger.error("Non numeric characters detected in header.")
            return
        }
        let start = prefixLength + nameCount
        let startIndex = message.index(message.startIndex, offsetBy: start)
        let header = message.prefix(start)
        let content = String(message.suffix(from: startIndex))
        let name = header.suffix(from: header.index(header.startIndex, offsetBy: prefixLength))
        let msg = Message(sender: Sender(senderId: user, displayName: String(name)),
                          messageId: UUID().uuidString,
                          sentDate: Date(), kind: .text(content))
        chatList.append(msg)
        chatBox?.onReceiveMessage(msg)
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
