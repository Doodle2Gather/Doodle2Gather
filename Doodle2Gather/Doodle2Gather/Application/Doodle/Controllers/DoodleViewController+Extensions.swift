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
            destination.roomWSController = self.roomWSController
            for user in userAccesses {
                destination.userIdToNameMapping[user.userId] = user.displayName
            }
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
            destination.userAccesses = userAccesses
            invitationDelegate = destination
            guard let room = room else {
                return
            }
            destination.room = room
            destination.roomWSController = roomWSController
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
        let sortedDoodles = doodles.sorted { a, b in
            a.createdAt < b.createdAt
        }
        canvasController?.loadDoodles(sortedDoodles)
        layerTable?.loadDoodles(sortedDoodles)
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

    func didUpdateUserAccesses(_ users: [DTAdaptedUserAccesses]) {
        userAccesses = users.sorted(by: { x, y -> Bool in
            x.displayName < y.displayName
        })
        let currentUserAccess = userAccesses.first { x -> Bool in
            x.userId == DTAuth.user?.uid
        }
        DispatchQueue.main.async {
            self.setCanEdit(currentUserAccess?.canEdit ?? false)
        }
        invitationDelegate?.didUpdateUserAccesses(userAccesses)
    }

    func updateUsers(_ users: [DTAdaptedUser]) {
        let states = users.map({ u -> UserState in
            UserState(userId: u.id, displayName: u.displayName, email: u.email)
        }).sorted(by: { x, y -> Bool in
            x.displayName < y.displayName
        })
        userStates.removeAll()
        for index in 0..<(states.count - 1) where states[index].userId
            != states[index + 1].userId {
            userStates.append(states[index])
        }
        userStates.append(states[states.count - 1])

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

    @IBAction private func selectToolButtonDidTap(_ sender: UIButton) {
        guard let toolSelected = SelectTools(rawValue: sender.tag) else {
            return
        }
        unselectAllSelectTools()
        sender.isSelected = true
        setSelectTool(toolSelected)
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
