protocol DTAuthDelegate: AnyObject {
    func displayError(_ error: Error)
    func displayMessage(_ message: String)
    func loginDidSucceed()
    func registerDidSucceed()
}
