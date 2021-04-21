import Vapor
import Fluent
import DTSharedLibrary

struct WSConnectionController: RouteCollection {
    private let webSocketController: WebSocketController

    init(db: Database) {
        self.webSocketController = WebSocketController(db: db)
    }

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket(maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 24),
                         onUpgrade: self.upgradedWebSocket)
    }

    func upgradedWebSocket(req: Request, ws: WebSocket) {
        ws.onBinary { ws, buffer in
            guard let data = buffer.getData(
                    at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }
            self.decodeReceivedData(ws, data)
        }
        ws.onText { ws, text in
            guard let data = text.data(using: .utf8) else {
                return
            }
            self.decodeReceivedData(ws, data)
        }
        webSocketController.onConnect(ws)
    }

    private func runReceiveDataMiddlewares(_ data: Data) -> Data {
        // Dummy method for server receive middlewares
        data
    }

    private func decodeReceivedData(_ ws: WebSocket, _ data: Data) {
        let decodedData = runReceiveDataMiddlewares(data)
        webSocketController.onData(ws, decodedData)
    }

}
