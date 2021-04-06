import DTFrontendLibrary
import DTSharedLibrary

protocol SocketControllerDelegate: AnyObject {

    func dispatchAction(_ action: DTNewAction)

    func clearDrawing()

    func loadDoodles(_ doodles: [DTAdaptedDoodle])

}
