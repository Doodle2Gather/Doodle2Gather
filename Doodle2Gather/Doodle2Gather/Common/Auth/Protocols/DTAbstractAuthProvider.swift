import DTSharedLibrary

protocol DTAbstractAuthProvider {
    var delegate: DTAuthDelegate? { get set }
    var user: DTUser? { get }
    func signUp(email: String, password: String, displayName: String)
    func login(email: String, password: String)
}
