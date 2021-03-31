protocol DTAbstractLogger {
    func debug(_ message: String)
    func debug(_ message: @escaping () -> String)
    func info(_ message: String)
    func info(_ message: @escaping () -> String)
    func event(_ message: String)
    func event(_ message: @escaping () -> String)
    func warn(_ message: String)
    func warn(_ message: @escaping () -> String)
    func error(_ message: String)
    func error(_ message: @escaping () -> String)
}
