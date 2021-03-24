//
//  ChatViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 24/3/21.
//

import UIKit

protocol ChatEngine {
    var delegate: ChatEngineDelegate? { get set }
    func initialize()
    func joinChannel(channelName: String)
    func send(message: String)
}

protocol ChatEngineDelegate: AnyObject {
    func deliverMessage(from user: String, message: String)
}

struct Message {
    var userId: String
    var text: String
}

class ChatViewController: UIViewController {
    var chatEngine: ChatEngine?
    lazy var list = [Message]()
    var account = UIDevice.current.name

    override func viewDidLoad() {
        super.viewDidLoad()
        chatEngine = AgoraChatEngine()
        list.append(Message(userId: "Wang", text: "How are you?"))
        list.append(Message(userId: "Wang", text: "How are you?"))
        list.append(Message(userId: "Wang", text: "How are you?"))
        list.append(Message(userId: "Wang", text: "How are you?"))

        // Do any additional setup after loading the view.
    }

    func pressedReturnToSendText(_ text: String?) -> Bool {
        guard let text = text, !text.isEmpty else {
            return false
        }
        chatEngine?.send(message: text)
        return true
    }
}

extension ChatViewController: ChatEngineDelegate {
    func deliverMessage(from user: String, message: String) {
        self.list.append(Message(userId: user, text: message))
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if pressedReturnToSendText(textField.text) {
            textField.text = nil
        } else {
            view.endEditing(true)
        }

        return true
    }
}
