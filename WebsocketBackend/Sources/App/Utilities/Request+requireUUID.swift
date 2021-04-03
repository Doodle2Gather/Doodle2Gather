import Vapor

extension Request {
    func requireUUID(parameterName: String) throws -> UUID {
        guard let idString = parameters.get(parameterName) else {
            throw DTError.missingParameter(name: parameterName)
        }
        guard let id = UUID(idString) else {
            throw DTError.invalidParameterFormat(name: parameterName, desiredType: "\(UUID.self)")
        }
        return id
    }
}
