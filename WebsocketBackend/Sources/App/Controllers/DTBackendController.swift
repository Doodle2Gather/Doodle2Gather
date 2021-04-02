import Vapor

struct DTBackendController: RouteCollection {
    let wsController: WebSocketController

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("rooms", "devRoom",
                         maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 24),
                         onUpgrade: self.webSocket)
        routes.get(use: index)
    }

    func webSocket(req: Request, socket: WebSocket) {
        self.wsController.connect(socket)x
    }

    struct DoodleActionContext: Encodable {
        let actions: [PersistedDTAction]
    }

    func index(req: Request) throws -> EventLoopFuture<View> {
        PersistedDTAction.query(on: req.db).all().flatMap {
            req.view.render("actions", DoodleActionContext(actions: $0))
        }
    }
}
