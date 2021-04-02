import Willow

class WillowLogger: DTAbstractLogger {
    private let logger = Logger(logLevels: .all,
                                writers: [ConsoleWriter(modifiers: [
                                                            // TimestampModifier(),
                                                            LogLevelModifier()])],
                                executionMethod: .synchronous(lock: NSRecursiveLock()))

    func debug(_ message: String) {
        logger.debugMessage(message)
    }

    func debug(_ message: @escaping () -> String) {
        logger.debugMessage(message)
    }

    func info(_ message: String) {
        logger.infoMessage(message)
    }

    func info(_ message: @escaping () -> String) {
        logger.infoMessage(message)
    }

    func event(_ message: String) {
        logger.eventMessage(message)
    }

    func event(_ message: @escaping () -> String) {
        logger.eventMessage(message)
    }

    func warn(_ message: String) {
        logger.warnMessage(message)
    }

    func warn(_ message: @escaping () -> String) {
        logger.warnMessage(message)
    }

    func error(_ message: String) {
        logger.errorMessage(message)
    }

    func error(_ message: @escaping () -> String) {
        logger.errorMessage(message)
    }

}

class LogLevelModifier: LogModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        "[\(logLevel.description)] \(message)"
    }
}
