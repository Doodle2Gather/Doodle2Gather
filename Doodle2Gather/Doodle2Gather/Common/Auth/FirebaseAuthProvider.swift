import Firebase
import DoodlingLibrary

class FirebaseAuthProvider: DTAbstractAuthProvider {

    init() {
    }

    weak var delegate: DTAuthDelegate?

    private var fbUser: User? {
        Auth.auth().currentUser
    }

    private var storedUser: DTUser?

    var user: DTUser? {
        if self.storedUser == nil {
            self.storedUser = Auth.auth().currentUser?.toDTUser()
        }
        return self.storedUser!
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
        guard let fbUser = fbUser else {
            DTLogger.error("Unable to get logged in user")
            return
        }
        let changeRequest = fbUser.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { error in
            guard error == nil else {
                DTLogger.error("Unable set user profile display name")
                return
            }
        }
    }
}

extension User {
    func toDTUser() -> DTUser {
        guard let displayName = displayName,
              let email = email else {
            fatalError("Unable to get account info")
        }
        return DTUser(uid: uid, displayName: displayName, email: email)
    }
}
