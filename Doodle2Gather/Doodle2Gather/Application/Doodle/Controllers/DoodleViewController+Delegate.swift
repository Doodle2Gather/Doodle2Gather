import Foundation
import DTSharedLibrary

// MARK: - Delegate Implementations

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
        userIcons = existingUsers.map({ x -> UserIconData in
            UserIconData(user: x, color: generateRandomColor())
        })
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
