protocol SocketControllerDelegate: AnyObject {

    func dispatchAction(_ action: DTAction)

    func handleConflict(_ undoAction: DTAction, histories: [DTAction])

    func clearDrawing()

}
