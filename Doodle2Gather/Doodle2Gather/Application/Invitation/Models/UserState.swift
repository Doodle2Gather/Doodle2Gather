struct UserState: Hashable {
    let userId: String
    let displayName: String
    let email: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
}
