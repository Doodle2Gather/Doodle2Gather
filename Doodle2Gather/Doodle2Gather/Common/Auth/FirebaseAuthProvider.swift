import Firebase
import DTSharedLibrary

class FirebaseAuthProvider: DTAbstractAuthProvider {

    init() {
    }

    weak var delegate: DTAuthDelegate?

    private var fbUser: User? {
        Auth.auth().currentUser
    }

    var user: DTUser? {
        Auth.auth().currentUser?.toDTUser()
    }

    func signUp(email: String, password: String, displayName: String) {
      Auth.auth().createUser(withEmail: email, password: password) { _, error in
        guard error == nil else {
            self.delegate?.displayError(error!)
            return
        }
        self.setUserDisplayName(displayName)
        self.delegate?.registerDidSucceed()
      }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else {
                self.delegate?.displayError(error!)
                return
            }
            DTLogger.info("Logged in")
            DTApi.sendUserData(id: self.user!.uid,
                               displayName: self.user!.displayName,
                               email: self.user!.email) {
                self.delegate!.loginDidSucceed()
            }
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
            DTLogger.info("Display name is now set to: \(displayName)")
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
