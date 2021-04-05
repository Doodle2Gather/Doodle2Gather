/// Represents a controller that managers a web socket.
protocol SocketController {
    func addAction(_ action: DTNewAction)

    func clearDrawing()

    func refetchDoodles()
}
