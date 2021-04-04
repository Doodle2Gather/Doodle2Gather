protocol DTUserCredentialsProvider {
    var hasSavedCredentials: Bool { get }
    var savedEmail: String? { get set }
    var savedPassword: String? { get set }
}
