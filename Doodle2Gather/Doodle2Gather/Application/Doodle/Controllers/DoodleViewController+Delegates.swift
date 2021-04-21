import DTSharedLibrary
import UIKit

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
        if let loadingSpinner = self.loadingSpinner {
            self.removeSpinnerView(loadingSpinner)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let loadingSpinner = self.loadingSpinner {
                self.removeSpinnerView(loadingSpinner)
            }
        }
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
            self.updateProfileIcons()
        }
    }

}

// MARK: - CanvasControllerDelegate

extension DoodleViewController: CanvasControllerDelegate {

    func dispatchPartialAction(_ action: DTPartialAdaptedAction) {
        guard let roomId = self.room?.roomId else {
            return
        }
        let action = DTAdaptedAction(partialAction: action, roomId: roomId)
        roomWSController.addAction(action)
        updateUndoRedoButtons()
    }

    func canvasZoomScaleDidChange(scale: CGFloat) {
        let scale = min(UIConstants.maxZoom, max(UIConstants.minZoom, scale))
        setZoomText(scalePercent: Int(scale * 100))
    }

    func refetchDoodles() {
        if loadingSpinner == nil {
            loadingSpinner = self.createSpinnerView(message: "Refetching Doodles...")
        }
        roomWSController.refetchDoodles()
    }

    func strokeDidSelect(color: UIColor) {
        leftPanelsController?.strokeDidSelect(color: color)
    }

    func strokeDidUnselect() {
        leftPanelsController?.strokeDidUnselect()
    }

    func setCanEdit(_ canEdit: Bool) {
        leftPanelsController?.setCanEdit(canEdit)
        canvasController?.setCanEdit(canEdit)
    }

}

extension DoodleViewController: LeftPanelsControllerDelegate {

    func setMainTool(_ mainTool: MainTools) {
        canvasController?.setMainTool(mainTool)
    }

    func setDrawingTool(_ drawingTool: DrawingTools) {
        canvasController?.setDrawingTool(drawingTool)
    }

    func setShapeTool(_ shapeTool: ShapeTools) {
        canvasController?.setShapeTool(shapeTool)
    }

    func setSelectTool(_ selectTool: SelectTools) {
        canvasController?.setSelectTool(selectTool)
    }

    func setWidth(_ width: CGFloat) {
        canvasController?.setWidth(width)
    }

    func setColor(_ color: UIColor) {
        canvasController?.setColor(color)
    }

    func setIsPressureSensitive(_ isPressureSensitive: Bool) {
        canvasController?.setIsPressureSensitive(isPressureSensitive)
    }

}
