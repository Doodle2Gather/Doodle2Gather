import DTSharedLibrary

protocol SocketControllerDelegate: AnyObject {

    func dispatchAction(_ action: DTAction)

    func clearDrawing()

    func loadDoodles(_ doodles: [DTAdaptedDoodle])

    func updateUsers(_ users: [DTAdaptedUser])

}
