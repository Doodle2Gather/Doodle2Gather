import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    var chatEngine: ChatEngine?
    var messages = [Message]()
    var account = ConferenceConstants.testUser
    var currentUser = Sender(senderId: ConferenceConstants.testUser,
                             displayName: ConferenceConstants.testUser)
    var deliverHandler: ((Message) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardObserver()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        layout.textMessageSizeCalculator.incomingMessageTopLabelAlignment.textInsets =
            UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        layout.textMessageSizeCalculator.outgoingMessageTopLabelAlignment.textInsets =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)

        messageInputBar.delegate = self

        messageInputBar.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
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
     @objc func dismissKeyboard() {
         // Causes the view (or one of its embedded text fields) to resign the first responder status
         view.endEditing(true)
     }

     // Handle keyboard blocking input area
     @objc func keyboardFrameWillChange(notification: NSNotification) {
         guard let userInfo
                 = notification.userInfo,
               let endKeyboardFrameValue
                 = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
               let durationValue
                 = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
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
                    strongSelf.messagesCollectionView.contentInset = UIEdgeInsets(top: 10,
                                                                                  left: 10,
                                                                                  bottom: offsetY + 44,
                                                                                  right: 10)
                 }
             } else {
                strongSelf.messagesCollectionView.contentInset = UIEdgeInsets(top: 10,
                                                                              left: 10,
                                                                              bottom: 20,
                                                                              right: 10)
             }
             strongSelf.view.layoutIfNeeded()
             if !strongSelf.messages.isEmpty {
                 strongSelf.messagesCollectionView.scrollToLastItem()
             }
         }
     }
}

// MARK: - ChatBoxDelegate
// Receives message from ConferenceViewController

extension ChatViewController: ChatBoxDelegate {
    func onReceiveMessage(from user: String, message: String) {
        let msg = Message(sender: Sender(senderId: user, displayName: user),
                          messageId: UUID().uuidString,
                          sentDate: Date(),
                          kind: .text(message))
        messages.append(msg)
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
        20
    }

    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {

        NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                         .foregroundColor: UIColor.darkGray])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func messagePadding(for message: MessageType,
                        at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func messageLabelInset(for message: MessageType,
                           at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message)
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

        // Send message through chat engine
        chatEngine?.send(message: text)
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
        inputBar.inputTextView.text = ""
    }
}
