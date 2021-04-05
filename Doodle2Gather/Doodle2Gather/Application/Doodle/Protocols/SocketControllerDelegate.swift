import DTFrontendLibrary

protocol SocketControllerDelegate: AnyObject {

    func dispatchAction(_ action: DTNewAction)

    func clearDrawing()

    func loadDoodles<D: DTDoodle>(_ doodles: [D])

}
