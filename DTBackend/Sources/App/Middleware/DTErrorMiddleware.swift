import Vapor

/// Encodes `DTError` into `DTErrorResponse`
public final class DTErrorMiddleware: Middleware {
  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    next.respond(to: request).flatMapErrorThrowing { error in
      if let tilError = error as? DTError {

        let errorResponse = DTErrorResponse(tilError)
        let status = HTTPResponseStatus(statusCode: Int(errorResponse.statusCode))
        let response = Response(status: status)
        response.body = .init(data: try JSONEncoder().encode(errorResponse))
        response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
      } else {
        throw error // Let the `ErrorMiddleware` handle other errors
      }
    }
  }
}
