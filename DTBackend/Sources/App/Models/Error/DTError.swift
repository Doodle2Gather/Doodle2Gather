import Vapor

public struct DTError: Error {
    public enum ErrorIdentifier: String, Codable {
        case missingParameter
        case invalidParameterFormat
        case modelNotFound
        case unableToRetreiveID
        case other
    }

    public let errorIdentifier: ErrorIdentifier
    public let reason: String

    public static func missingParameter(name: String) -> DTError {
        DTError(
            errorIdentifier: .missingParameter,
            reason: "Parameter `\(name)` is missing."
        )
    }

    public static func invalidParameterFormat(name: String, desiredType: String) -> DTError {
        DTError(
            errorIdentifier: .invalidParameterFormat,
            reason: "Parameter `\(name)` has wrong type (expected: `\(desiredType)`)."
        )
    }

    public static func modelNotFound(type: String) -> DTError {
        DTError(
            errorIdentifier: .modelNotFound,
            reason: "Model of type `\(type)` not found"
        )
    }

    public static func modelNotFound(type: String, id: String) -> DTError {
        DTError(
            errorIdentifier: .modelNotFound,
            reason: "Model of type `\(type)` with ID `\(id)` not found"
        )
    }

    public static func modelNotFound(type: String, code: String) -> DTError {
        DTError(
            errorIdentifier: .modelNotFound,
            reason: "Model of type `\(type)` with code `\(code)` not found"
        )
    }

    public static func unableToRetreiveID(type: String) -> DTError {
        DTError(
            errorIdentifier: .missingParameter,
            reason: "Model of type `\(type)` has no ID assigned."
        )
    }

    public static func other(description: String) -> DTError {
        DTError(
            errorIdentifier: .missingParameter,
            reason: "Other error: \(description)"
        )
    }

    public init(errorIdentifier: ErrorIdentifier, reason: String) {
        self.errorIdentifier = errorIdentifier
        self.reason = reason
    }
}

extension DTError: AbortError {
    public var status: HTTPResponseStatus {
        switch self.errorIdentifier {
        case .missingParameter:
            return .badRequest
        case .invalidParameterFormat:
            return .badRequest
        case .modelNotFound:
            return .notFound
        case .unableToRetreiveID:
            return .internalServerError
        case .other:
            return .internalServerError
        }
    }
}

// MARK: - DTErrorResponse

extension DTError: DebuggableError {
    public var identifier: String { errorIdentifier.rawValue }
}

public struct DTErrorResponse: Codable {
    public let error: String
    public let identifier: DTError.ErrorIdentifier
    public let reason: String
    public let statusCode: UInt

    public init(
        identifier: DTError.ErrorIdentifier,
        reason: String,
        statusCode: UInt
    ) {
        self.error = "true"
        self.identifier = identifier
        self.reason = reason
        self.statusCode = statusCode
    }
}

extension DTError {
    public init(_ errorResponse: DTErrorResponse) {
        self.init(errorIdentifier: errorResponse.identifier, reason: errorResponse.reason)
    }
}

extension DTErrorResponse {
    init(_ error: DTError) {
        self.init(
            identifier: error.errorIdentifier,
            reason: error.reason,
            statusCode: error.status.code
        )
    }
}
