import Firebase

protocol DTAbstractAuthProvider {
    var delegate: DTAuthDelegate? { get set }
    var user: User? { get }
    func signUp(email: String, password: String, displayName: String)
    func login(email: String, password: String)
}

protocol DTAuthDelegate: AnyObject {
    func displayError(_ error: Error)
    func loginDidSucceed()
}

class FirebaseAuthProvider: DTAbstractAuthProvider {

    init() {
    }

    weak var delegate: DTAuthDelegate?
    var user: User? {
        Auth.auth().currentUser
    }

    func signUp(email: String, password: String, displayName: String) {
      Auth.auth().createUser(withEmail: email, password: password) { _, error in
        guard error == nil else {
            self.delegate?.displayError(error!)
            return
        }
        self.setUserDisplayName(displayName)
        self.delegate?.loginDidSucceed()
      }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else {
                self.delegate?.displayError(error!)
                return
            }
        self.delegate?.loginDidSucceed()
        }
    }

    private func setUserDisplayName(_ displayName: String) {
        guard let user = user else {
            DTLogger.error("Unable to get logged in user")
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { error in
            guard error == nil else {
                DTLogger.error("Unable set user profile display name")
                return
            }
        }
    }
}
