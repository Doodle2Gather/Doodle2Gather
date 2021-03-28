//
//  ChatViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 24/3/21.
//

import UIKit

struct Message {
    var userId: String
    var text: String
}

class ChatViewController: UIViewController {
    @IBOutlet private var inputTextField: UITextField!
    @IBOutlet private var sendButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var inputContainerView: UIView!
    @IBOutlet private var inputBottomConstraint: NSLayoutConstraint!

    var chatEngine: ChatEngine?
    lazy var list = [Message]()
    var account = ConferenceConstants.testUser
    var deliverHandler: ((Message) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        addKeyboardObserver()
    }

    // Make table cell height dynamic
     func updateViews() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = ConferenceConstants.messageCellHeight
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
     }

    @IBAction private func send(_ sender: Any) {
        guard let text = inputTextField.text else {
            return
        }
        guard !text.isEmpty else {
            return
        }
        chatEngine?.send(message: text)
        inputTextField.text = ""
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardFrameWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let endKeyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
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
                guard offsetY > 0 else {
                    return
                }
                strongSelf.inputBottomConstraint.constant = -offsetY - strongSelf.inputContainerView.frame.height - 44
            } else {
                strongSelf.inputBottomConstraint.constant = -20
            }
            strongSelf.view.layoutIfNeeded()
        }
    }
}

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

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = list[indexPath.row]
        let type: CellType = msg.userId == self.account ? .right : .left
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageViewCell
        cell?.update(type: type, message: msg)
        return cell!
    }
}
