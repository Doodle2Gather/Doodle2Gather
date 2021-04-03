protocol DTAuthDelegate: AnyObject {
    func displayError(_ error: Error)
    func loginDidSucceed()
}
