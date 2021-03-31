//
//  ParticipantsViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 31/3/21.
//

import UIKit

class ParticipantsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    var participants = [Participant]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        participants.append(Participant(userId: "1", displayName: "Trump", isVideoOn: true, isAudioOn: true))
        participants.append(Participant(userId: "2", displayName: "Putin", isVideoOn: true, isAudioOn: true))
        participants.append(Participant(userId: "3", displayName: "Obama", isVideoOn: true, isAudioOn: true))
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ParticipantsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        participants.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participant = participants[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell",
                                                 for: indexPath) as? ParticipantViewCell
        cell?.displayName = participant.displayName
        cell?.userId = participant.userId
        cell?.isAudioOn = participant.isAudioOn
        cell?.isVideoOn = participant.isVideoOn
        return cell!
    }
}

extension ParticipantsViewController: UITableViewDelegate {

}
