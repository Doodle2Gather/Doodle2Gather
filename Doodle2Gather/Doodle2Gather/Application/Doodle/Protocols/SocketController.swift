/// Represents a controller that managers a web socket.
protocol SocketController {
    func addAction(_ action: DTAction)

    func clearDrawing()

    func refetchDoodles()
}
