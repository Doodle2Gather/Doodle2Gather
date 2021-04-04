import DoodlingLibrary

class DTAuth {
    static let shared = DTAuth()
    private var authProvider: DTAbstractAuthProvider = FirebaseAuthProvider()

    static var delegate: DTAuthDelegate? {
        get { shared.authProvider.delegate }
        set { shared.authProvider.delegate = newValue }
    }

    static var user: DTUser? {
        shared.authProvider.user
    }

    static func signUp(email: String, password: String, displayName: String) {
        shared.authProvider.signUp(email: email, password: password, displayName: displayName)
    }

    static func login(email: String, password: String) {
        shared.authProvider.login(email: email, password: password)
    }
}
