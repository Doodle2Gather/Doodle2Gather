class DTLogger {
    private static let shared = DTLogger()
    private var logger: DTAbstractLogger = WillowLogger()
    
    static func debug(_ message: String) {
        shared.logger.debug(message)
    }

    static func debug(_ message: @escaping () -> String) {
        shared.logger.debug(message)
    }

    static func info(_ message: String) {
        shared.logger.info(message)
    }

    static func info(_ message: @escaping () -> String) {
        shared.logger.event(message)
    }

    static func event(_ message: String) {
        shared.logger.event(message)
    }

    static func event(_ message: @escaping () -> String) {
        shared.logger.warn(message)
    }

    static func warn(_ message: String) {
        shared.logger.warn(message)
    }

    static func warn(_ message: @escaping () -> String) {
        shared.logger.warn(message)
    }

    static func error(_ message: String) {
        shared.logger.error(message)
    }

    static func error(_ message: @escaping () -> String) {
        shared.logger.error(message)
    }

 }
