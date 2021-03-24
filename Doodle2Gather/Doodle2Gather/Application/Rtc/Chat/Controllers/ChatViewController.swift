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
}

protocol ChatEngineDelegate: AnyObject {
    func didJoinChat(id: UInt)
    func didLeaveChat(id: UInt)
}

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
