import Foundation
import DTSharedLibrary

// MARK: - Delegate Implementations

// MARK: - SocketControllerDelegate

extension DoodleViewController: SocketControllerDelegate {

    func dispatchAction(_ action: DTAction) {
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
        existingUsers = users
        if userIconColors.isEmpty {
            for _ in 0..<50 {
                userIconColors.append(generateRandomColor())
            }
            DispatchQueue.main.async {
                self.updateProfileColors()
            }
        }
    }

}

// MARK: - DoodleLayerTableDelegate

extension DoodleViewController: DoodleLayerTableDelegate {

    func selectedDoodleDidChange(index: Int) {
        canvasController?.setSelectedDoodle(index: index)
    }

}
