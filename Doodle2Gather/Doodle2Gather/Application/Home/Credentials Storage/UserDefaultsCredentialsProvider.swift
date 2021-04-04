import Foundation

class UserDefaultsCredentialsProvider: DTUserCredentialsProvider {
    private let emailKey = "email"
    private let passwordKey = "password"

    private let defaults = UserDefaults.standard

    var hasSavedCredentials: Bool {
        defaults.object(forKey: emailKey) != nil && defaults.object(forKey: passwordKey) != nil
    }

    var savedEmail: String? {
        get {
            defaults.object(forKey: emailKey) as? String
        }
        set {
            defaults.set(newValue, forKey: emailKey)
        }
    }

    var savedPassword: String? {
        get {
            defaults.object(forKey: passwordKey) as? String
        }
        set {
            defaults.set(newValue, forKey: passwordKey)
        }
    }

}
