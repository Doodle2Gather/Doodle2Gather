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

    var chatEngine: ChatEngine?
    lazy var list = [Message]()
    var account = RtcConstants.testUser
    var deliverHandler: ((Message) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {
            guard let vc = segue.destination as? ConferenceViewController else {
                fatalError("Unable to get ConferenceViewController")
            }
            vc.chatList.removeAll()
            for msg in list {
                vc.chatList.append(msg)
            }
        }
    }

    @IBAction private func send(_ sender: Any) {
        guard let text = inputTextField.text else {
            return
        }
        chatEngine?.send(from: account, message: text)
        inputTextField.text = ""
        tableView.reloadData()
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: ChatBoxDelegate {
    func onReceiveMessage(_ message: Message) {
        list.append(message)
        if list.count > 100 {
            list.removeFirst()
        }
        let end = IndexPath(row: self.list.count - 1, section: 0)

        tableView.reloadData()
        tableView.scrollToRow(at: end, at: .bottom, animated: true)
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

extension ChatViewController: UITextFieldDelegate {
}
