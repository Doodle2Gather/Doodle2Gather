import Vapor

struct DTWebSocketController: RouteCollection {
    let wsController: WebSocketController

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("rooms", "devRoom",
                         maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 24),
                         onUpgrade: self.webSocket)
    }

    func webSocket(req: Request, socket: WebSocket) {
        self.wsController.connect(socket)
    }
}
