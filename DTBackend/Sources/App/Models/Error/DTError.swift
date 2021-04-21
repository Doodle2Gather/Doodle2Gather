import Vapor

/// Potential errors when quering database
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

}
