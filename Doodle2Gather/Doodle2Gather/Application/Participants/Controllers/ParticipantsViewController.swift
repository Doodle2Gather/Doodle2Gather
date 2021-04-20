import UIKit
import DTSharedLibrary

class ParticipantsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    var participants = [DTAdaptedUserConferenceState]()

    override func viewDidLoad() {
        super.viewDidLoad()

        print(participants)
        isModalInPresentation = true
    }

    @IBAction private func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

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
        cell?.userId = participant.id
        cell?.isAudioOn = participant.isAudioOn
        cell?.isVideoOn = participant.isVideoOn
        return cell!
    }
}

// MARK: - UITableViewDelegate

extension ParticipantsViewController: UITableViewDelegate {

}
