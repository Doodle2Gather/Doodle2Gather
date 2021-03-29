import UIKit

struct Message {
    var userId: String
    var text: String
}

class ChatViewController: UIViewController {
    @IBOutlet private var inputTextView: UITextView!
    @IBOutlet private var sendButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inputContainerView: UIView!
    @IBOutlet private var inputBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var textBoxAndButton: UIView!
    
    var chatEngine: ChatEngine?
    lazy var list = [Message]()
    var account = ConferenceConstants.testUser
    var deliverHandler: ((Message) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        addKeyboardObserver()
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // Handle change of orientation for chat box
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            self.inputBottomConstraint.constant = 0
        }
    }

    func updateViews() {
        // Set table cell height to be dynamic
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = ConferenceConstants.messageCellHeight

        // Style input text box
        inputTextView.layer.borderWidth = ConferenceConstants.defaultBorderWidth
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.cornerRadius = ConferenceConstants.defaultCornerRadius
        inputTextView.text = ConferenceConstants.placeholderText
        inputTextView.textColor = .lightGray
        inputTextView.textContainerInset = ConferenceConstants.textBoxDefaultInsets
        inputTextView.isScrollEnabled = false
        inputTextView.sizeToFit()
        inputTextView.delegate = self
        
        // Add top border to the input area
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0,
                                 width: textBoxAndButton.frame.size.width,
                                 height: ConferenceConstants.defaultBorderWidth)
        topBorder.backgroundColor = UIColor.systemGray5.cgColor
        textBoxAndButton.layer.addSublayer(topBorder)
    }

    @IBAction private func send(_ sender: Any) {
        guard let text = inputTextView.text else {
            return
        }
        guard !text.isEmpty else {
            return
        }
        chatEngine?.send(message: text)
        inputTextView.text = ""
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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

        let isShowing: Bool = endKeyboardFrame.maxY > UIScreen.main.bounds.height ? false : true
        UIView.animate(withDuration: duration) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if isShowing {
                let offsetY = strongSelf.inputContainerView.frame.maxY - endKeyboardFrame.minY
                if offsetY < 0 {
                    return
                } else {
                    strongSelf.inputBottomConstraint.constant = -offsetY - 40
                }
            } else {
                strongSelf.inputBottomConstraint.constant = 0
            }
            strongSelf.view.layoutIfNeeded()
            if !strongSelf.list.isEmpty {
                let end = IndexPath(row: strongSelf.list.count - 1, section: 0)
                strongSelf.tableView.scrollToRow(at: end, at: .bottom, animated: false)
            }
        }
    }
}

// MARK: - ChatBoxDelegate
// Receives message from ConferenceViewController

extension ChatViewController: ChatBoxDelegate {
    func onReceiveMessage(_ message: Message) {
        self.list.append(message)
        if self.list.count > 100 {
            self.list.removeFirst()
        }
        let end = IndexPath(row: self.list.count - 1, section: 0)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: end, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = list[indexPath.row]
        let type: CellType = msg.userId == self.account ? .right : .left
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell",
                                                 for: indexPath) as? MessageViewCell
        cell?.update(type: type, message: msg)
        return cell!
    }
}

// MARK: - UITextViewDelegate
// Handles placeholder text

extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your message here..."
            textView.textColor = .lightGray
        }
    }
}
