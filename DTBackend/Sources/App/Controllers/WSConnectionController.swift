import Vapor
import Fluent
import DTSharedLibrary
import SWCompression

struct WSConnectionController: RouteCollection {
    private let webSocketController: WebSocketController
    private let logger = Logger(label: "WSConnectionController")

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

    private func runReceiveDataMiddlewares(_ data: Data) throws -> Data {
        let decompressedData = try ZlibArchive.unarchive(archive: data)
        return decompressedData
    }

    private func decodeReceivedData(_ ws: WebSocket, _ data: Data) {
        do {
            let decodedData = try runReceiveDataMiddlewares(data)
            webSocketController.onData(ws, decodedData)
        } catch {
            logger.warning("Unable to decode incoming data: \(error.localizedDescription)")
        }
    }

}
