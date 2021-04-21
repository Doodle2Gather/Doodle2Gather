import Foundation
import Vapor
import SWCompression

extension WebSocket {
    private static let _lock = Lock()
    private static let logger = Logger(label: "WebSocket+Send")

    func send<T: Codable>(message: T, id: UUID) {
        WebSocket.logger.info("Sent \(message.self) to \(id)")
        send(message: message)
    }

    func send<T: Codable>(message: T) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            let encodedData = encodeSendData(data)
            WebSocket._lock.withLockVoid {
                self.send(raw: encodedData, opcode: .binary)
            }
        } catch {
            WebSocket.logger.report(error: error)
        }
    }

    private func runSendDataMiddlewares(_ data: Data) -> Data {
        let compressedData = ZlibArchive.archive(data: data)
        return compressedData
    }

    private func encodeSendData(_ data: Data) -> Data {
        let encodedData = runSendDataMiddlewares(data)
        return encodedData
    }
}
