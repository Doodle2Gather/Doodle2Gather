import UIKit
import EasyNotificationBadge
import DTSharedLibrary

class ConferenceViewController: UIViewController {

    // UI Elements
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var timerButton: UIButton!
    @IBOutlet private var voteButton: UIButton!
    @IBOutlet private var startStopButton: UIButton!
    @IBOutlet private var participantsButton: UIButton!
    @IBOutlet private var videoButton: UIButton!
    @IBOutlet private var audioButton: UIButton!
    @IBOutlet private var chatButton: UIButton!
    @IBOutlet private var resizeButton: UIButton!
    @IBOutlet private var topControlViewContainer: UIView!
    @IBOutlet private var topControlView: UILabel!
    @IBOutlet private var toggleCallButton: UIButton!

    var videoEngine: VideoEngine?
    var chatEngine: ChatEngine?
    var chatBox: ChatBoxDelegate?
    var participants: [DTAdaptedUserConferenceState] = []
    lazy var chatList = [Message]()
    var isMuted = true
    var isVideoOff = true
    var isInCall = false
    var isChatShown = false
    var roomId: String?
    var videoCallUserList: [VideoCallUser] = []
    var roomWSController: DTRoomWebSocketController?

    private var timer = Timer()
    private var currentUser: VideoCallUser?
    private var currentUserOverlay: UIView?
    private var appearance = BadgeAppearance(animate: true)
    private var unreadMessageCount = 0

    enum VideoLabels {
        static let collapsed = "Minimized"
        static let gallery = "Gallery View"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoEngine = AgoraVideoEngine()
        videoEngine?.delegate = self
        videoEngine?.initialize()

        chatEngine = AgoraChatEngine()
        chatEngine?.initialize()
        chatEngine?.joinChannel(channelName: roomId ?? "testing")
        chatEngine?.delegate = self
        appearance.distanceFromCenterX = UIConstants.largeOffset
        appearance.distanceFromCenterY = -UIConstants.largeOffset

        videoEngine?.muteAudio()
        videoEngine?.hideVideo()
        videoButton.isHidden = true
        audioButton.isHidden = true
        collectionView.isHidden = true
        topControlViewContainer.isHidden = true

        timer = Timer.scheduledTimer(timeInterval: 2.0,
                                     target: self,
                                     selector: #selector(updateState),
                                     userInfo: nil,
                                     repeats: true)
        roomWSController?.conferenceDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.roomWSController?.updateConferencingState(isVideoOn: !self.isVideoOff, isAudioOn: !self.isMuted)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.timer.invalidate()
        }
    }

    @objc
    func updateState() {
        roomWSController?.updateConferencingState(isVideoOn: !isVideoOff, isAudioOn: !isMuted)
    }

    // Passes data to the ChatViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toChat:
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let vc = nav.topViewController as? ChatViewController else {
                return
            }
            chatEngine?.delegate = self
            vc.chatEngine = chatEngine
            isChatShown = true
            chatBox = vc
            vc.deliverHandler = { message in
                self.chatList.append(message)
            }
            vc.chatCallback = {
                self.unreadMessageCount = 0
                self.chatButton.badge(text: nil, appearance: self.appearance)
                self.isChatShown = false
            }
            for msg in chatList {
                vc.messages.append(msg)
            }
            unreadMessageCount = 0
            chatButton.badge(text: nil, appearance: appearance)
        case SegueConstants.toParticipants:
            guard let vc = segue.destination as? ParticipantsViewController else {
                return
            }
            vc.participants = participants
        default:
            return
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoEngine?.tearDown()
        chatEngine?.tearDown()
    }

    @IBAction private func audioButtonDidTap(_ sender: Any) {
        if isMuted {
            videoEngine?.unmuteAudio()
            isMuted = false
        } else {
            videoEngine?.muteAudio()
            isMuted = true
        }
        audioButton.isSelected = !isMuted
        roomWSController?.updateConferencingState(isVideoOn: !isVideoOff, isAudioOn: !isMuted)
    }

    @IBAction private func videoButtonDidTap(_ sender: Any) {

        if isVideoOff {
            videoEngine?.showVideo()
            currentUserOverlay?.removeFromSuperview()
            isVideoOff = false
        } else {
            videoEngine?.hideVideo()
            isVideoOff = true
            guard let cellView = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)),
                  let overlay = currentUserOverlay else {
                return
            }

            cellView.addSubview(overlay)
        }
        videoButton.isSelected = !isVideoOff
        roomWSController?.updateConferencingState(isVideoOn: !isVideoOff, isAudioOn: !isMuted)
    }

    @IBAction private func bottomMinimizeButtonDidTap(_ sender: UIButton) {
        timerButton.isHidden.toggle()
        voteButton.isHidden.toggle()
        chatButton.isHidden.toggle()
        startStopButton.isHidden.toggle()
        audioButton.isHidden.toggle()
        videoButton.isHidden.toggle()
        participantsButton.isHidden.toggle()
        sender.isSelected.toggle()
    }

    @IBAction private func didTapResizeButton(_ sender: UIButton) {
        collectionView.isHidden.toggle()
        if collectionView.isHidden {
            topControlView.text = VideoLabels.collapsed
        } else {
            topControlView.text = VideoLabels.gallery
        }
    }

    @IBAction private func didTapCall(_ sender: UIButton) {
        guard let user = DTAuth.user else {
            DTLogger.error("Attempt to toggle video without a user.")
            return
        }
        if isInCall {
            videoEngine?.tearDown()
            toggleCallButton.isSelected.toggle()
            collectionView.isHidden = true
            topControlViewContainer.isHidden = true
            videoCallUserList.removeAll()
            collectionView.reloadData()
            isInCall.toggle()
            videoButton.isHidden = true
            audioButton.isHidden = true
        } else {
            if currentUser == nil {
                let overlay = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: 200,
                                                   height: 112.5))
                overlay.backgroundColor = UIConstants.black
                currentUser = VideoCallUser(uid: 0,
                                            userId: user.uid)
                currentUserOverlay = overlay
            }
            videoEngine?.joinChannel(channelName: self.roomId ?? "testing")
            toggleCallButton.isSelected.toggle()
            collectionView.isHidden = false
            topControlViewContainer.isHidden = false
            videoButton.isHidden = false
            audioButton.isHidden = false
            isInCall.toggle()
        }
    }
}

// MARK: - VideoEngineDelegate

extension ConferenceViewController: VideoEngineDelegate {

    func didJoinCall(id: UInt, username: String) {
        let userObject = VideoCallUser(uid: id,
                                       userId: username)
        videoCallUserList.append(userObject)
        self.collectionView.reloadData()
    }

    func didLeaveCall(id: UInt, username: String) {
        if let index = videoCallUserList.firstIndex(where: { $0.uid == id }) {
            videoCallUserList.remove(at: index)
            self.collectionView.reloadData()
        }
    }

    func didUpdateUserInfo(id: UInt, username: String) {
        for index in 0..<videoCallUserList.count where videoCallUserList[index].uid == id {
            videoCallUserList[index].userId = username
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}

// MARK: - ChatEngineDelegate
// Receives message from the server and delivers the message to the delegate

extension ConferenceViewController: ChatEngineDelegate {

    func deliverMessage(from user: String, message: String) {
        guard let currentUser = DTAuth.user else {
            return
        }
        if currentUser.uid == user {
            AudioPlayer.shared.playSound(fileName: AudioConstants.send)
        } else {
            AudioPlayer.shared.playSound(fileName: AudioConstants.receive)
        }
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
        if !isChatShown {
            unreadMessageCount += 1
            chatButton.badge(text: "\(unreadMessageCount)", appearance: appearance)
        }
        chatBox?.onReceiveMessage(msg)
    }

}

// MARK: - UICollectionViewDelegate

extension ConferenceViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource

extension ConferenceViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videoCallUserList.count + 1
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
            let remoteID = videoCallUserList[indexPath.row - 1].uid
            DispatchQueue.main.async {
                self.videoEngine?.setupRemoteUserView(view: videoCell.getVideoView(), id: remoteID)
            }
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConferenceViewController: UICollectionViewDelegateFlowLayout {

    /// Computes the optimal layout for the collection view depending on the provided frame.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = collectionView.frame.width
            - collectionView.adjustedContentInset.left
            - collectionView.adjustedContentInset.right

        return CGSize(width: totalWidth, height: totalWidth * ConferenceConstants.aspectRatio)
    }

}

// MARK: - DTConferenceWebSocketControllerDelegate

extension ConferenceViewController: DTConferenceWebSocketControllerDelegate {

    /// Updates the conference states of the users currently in the room.
    func updateStates(_ users: [DTAdaptedUserConferenceState]) {
        participants = users
    }

}
