import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    // Engine
    var chatEngine: ChatEngine?

    // States
    var messages = [Message]()
    var account = ConferenceConstants.testUser
    var currentUser = Sender(senderId: DTAuth.user?.uid ?? UUID().uuidString,
                             displayName: DTAuth.user?.displayName ?? "Anonymous")

    // Callbacks for subviews / nested views
    var deliverHandler: ((Message) -> Void)?
    var chatCallback: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardObserver()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self

        updateViews()
        isModalInPresentation = true
    }

    // Customize chat view
    private func updateViews() {
        messagesCollectionView.contentInset = ConferenceConstants.defaultContentInset
        guard let layout = messagesCollectionView.collectionViewLayout
                as? MessagesCollectionViewFlowLayout else {
            return
        }
        layout.textMessageSizeCalculator.incomingMessageTopLabelAlignment.textInsets =
            ConferenceConstants.defaultLeftInset
        layout.textMessageSizeCalculator.outgoingMessageTopLabelAlignment.textInsets =
            ConferenceConstants.defaultRightInset
        layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets =
            ConferenceConstants.defaultLeftInset
        layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets =
            ConferenceConstants.defaultRightInset

        messageInputBar.layoutMargins = ConferenceConstants.messageInputBarInset
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    }

    // Handle change of orientation for chat box
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    // Tap anywhere else to dismiss the keyboard
    @objc
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status
        view.endEditing(true)
    }

    // Handle keyboard blocking input area
    @objc
    func keyboardFrameWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let endKeyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }

        let endKeyboardFrame = endKeyboardFrameValue.cgRectValue
        let duration = durationValue.doubleValue

        let isShowing: Bool = endKeyboardFrame.maxY
            > UIScreen.main.bounds.height ? false : true
        UIView.animate(withDuration: duration) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if isShowing {
                let offsetY = strongSelf.messagesCollectionView.frame.maxY - endKeyboardFrame.minY
                if offsetY < 0 {
                    return
                } else {
                    strongSelf.messagesCollectionView.contentInset =
                        ConferenceConstants.messageInputBarOffsetCalculator(offset: offsetY)
                }
            } else {
                strongSelf.messagesCollectionView.contentInset = ConferenceConstants.defaultContentInset
            }
            strongSelf.view.layoutIfNeeded()
            if !strongSelf.messages.isEmpty {
                strongSelf.messagesCollectionView.scrollToLastItem()
            }
        }
    }

    /// Formats the date.
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "H:m:ss"
        return formatter
    }()

    deinit {
      NotificationCenter.default.removeObserver(self)
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        if let callback = chatCallback {
            callback()
            dismiss(animated: true, completion: nil)
            return
        }
        DTLogger.error("No callback function provided to chat view controller.")
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - ChatBoxDelegate
// Receives message from ConferenceViewController

extension ChatViewController: ChatBoxDelegate {

    /// Upon receiving a message, it triggers an update to the messages in the chat box view.
    func onReceiveMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

}

// MARK: - UITableViewDataSource

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        currentUser
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }

    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section > 0
            && messages[indexPath.section].sender.senderId
            == messages[indexPath.section - 1].sender.senderId {
            return 0
        }
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType,
                                  at indexPath: IndexPath,
                                  in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        15
    }

    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {

        NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                         .foregroundColor: UIColor.darkGray])
    }

    func messageBottomLabelAttributedText(for message: MessageType,
                                          at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString,
                                  attributes: [NSAttributedString.Key.font:
                                                UIFont.preferredFont(forTextStyle: .caption2)])
    }

}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

    func messagePadding(for message: MessageType,
                        at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        UIConstants.messageViewInset
    }

    func messageLabelInset(for message: MessageType,
                           at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        UIConstants.messageViewInset
    }

}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {

    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId
            ? .bottomRight :
            .bottomLeft
        return .bubbleTail(corner, .curved)
    }

}

// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        let message = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Send message through chat engine
        chatEngine?.send(message: message)
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
        inputBar.inputTextView.text = ""
    }

}
