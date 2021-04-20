import DTSharedLibrary
import UIKit

// MARK: - Navigation Helpers

extension DoodleViewController {

    func prepareForSubviews(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas:
            guard let destination = segue.destination as? CanvasViewController else {
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
            destination.userIcons = userIcons
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

// MARK: - SocketControllerDelegate

extension DoodleViewController: DTRoomWebSocketControllerDelegate {

    func dispatchAction(_ action: DTAdaptedAction) {
        canvasController?.dispatchAction(action)
    }

    func loadDoodles(_ doodles: [DTDoodleWrapper]) {
        canvasController?.loadDoodles(doodles)
        layerTable?.loadDoodles(doodles)
    }

    func addNewDoodle(_ doodle: DTDoodleWrapper) {
        guard var doodles = canvasController?.getCurrentDoodles() else {
            return
        }
        doodles.append(doodle)
        self.doodles = doodles
        canvasController?.loadDoodles(doodles)
        layerTable?.loadDoodles(doodles)
    }

    func removeDoodle(doodleId: UUID) {
        // TODO: Add after refactoring doodles
    }

    func updateUsers(_ users: [DTAdaptedUserAccesses]) {
        existingUsers = users.sorted(by: { x, y -> Bool in
            x.displayName < y.displayName
        })
        userIcons.removeAll()
        for index in 0..<existingUsers.count {
            userIcons.append(UserIconData(user: existingUsers[index],
                                          color: userIconColors[index % UIConstants.userIconColorCount]))
        }
        DispatchQueue.main.async {
            self.updateProfileColors()
        }
    }

}

// MARK: - DoodleLayerTableDelegate

extension DoodleViewController: DoodleLayerTableDelegate {

    func selectedDoodleDidChange(index: Int) {
        canvasController?.setSelectedDoodle(index: index)
    }

}

// MARK: - IBActions Part 2

extension DoodleViewController {

    @IBAction private func exitButtonDidTap(_ sender: UIButton) {
        alert(title: AlertConstants.exit, message: AlertConstants.exitToMainMenu,
              buttonStyle: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    // TODO: Call backend to update the preview(s) to reflect the latest changes
                }
              }
        )
    }

    @IBAction private func drawingToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = DrawingTools(rawValue: sender.tag) else {
            return
        }
        unselectAllDrawingTools()
        sender.isSelected = true
        setDrawingTool(toolSelected)
        updatePressureView(toolSelected: toolSelected)
    }

    @IBAction private func shapeToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = ShapeTools(rawValue: sender.tag) else {
            return
        }
        unselectAllShapeTools()
        sender.isSelected = true
        setShapeTool(toolSelected)
    }

    @IBAction private func addLayerButtonDidTap(_ sender: UIButton) {
        roomWSController.addDoodle()
    }

    @IBAction private func undoButtonDidTap(_ sender: Any) {
        guard let canvasController = canvasController, canvasController.canUndo else {
            return
        }
        canvasController.undo()
    }

    @IBAction private func redoButtonDidTap(_ sender: Any) {
        guard let canvasController = canvasController, canvasController.canRedo else {
            return
        }
        canvasController.redo()
    }

    @IBAction private func pressureSwitchDidToggle(_ sender: UISwitch) {
        canvasController?.setIsPressureSensitive(sender.isOn)
    }

}
