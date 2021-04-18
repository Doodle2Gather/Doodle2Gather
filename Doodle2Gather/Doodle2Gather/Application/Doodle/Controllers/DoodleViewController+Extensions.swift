import UIKit

// MARK: - Navigation Helpers

extension DoodleViewController {

    func prepareForSubviews(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas:
            guard let destination = segue.destination as? DTCanvasViewController else {
                return
            }
            destination.delegate = self
            if let doodles = self.doodles {
                destination.loadDoodles(doodles)
            }
            self.canvasController = destination
        case SegueConstants.toStrokeEditor:
            guard let destination = segue.destination as? StrokeEditorViewController else {
                return
            }
            destination.delegate = self
            self.strokeEditor = destination
        case SegueConstants.toConference:
            guard let destination = segue.destination as? ConferenceViewController else {
                return
            }
            guard let roomId = room?.roomId?.uuidString else {
                return
            }
            destination.roomId = roomId
            // TODO: Fetch users from the socket controller and assign to the participants
            // TODO: Fetch all users who have permissions to the room and assign to the usersWithPermissions
        default:
            return
        }
    }

    func prepareForPopUps(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toLayerTable:
            guard let destination = segue.destination as? DoodleLayerTableViewController else {
                return
            }
            destination.delegate = self
            if let doodles = self.doodles {
                destination.loadDoodles(doodles)
            }
            self.layerTable = destination
        case SegueConstants.toInvitation:
            guard let destination = segue.destination as? InvitationViewController else {
                return
            }
            destination.modalPresentationStyle = .formSheet
            destination.existingUsers = existingUsers
            destination.userIconColors = userIconColors
            guard let room = room else {
                return
            }
            destination.room = room
        default:
            return
        }
    }

}

// MARK: - Random Color Generator

extension DoodleViewController {

    func generateRandomColor() -> UIColor {
        UIColor(
            red: .random(in: 0..<1),
            green: .random(in: 0..<1),
            blue: .random(in: 0..<1),
            alpha: 1.0
        )
    }

}
