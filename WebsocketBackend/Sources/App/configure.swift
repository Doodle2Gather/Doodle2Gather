import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // Configure Middleware
    app.middleware.use(DTErrorMiddleware())

    // Set up hostname and port
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8_080

    // Configure database
    app.databases.use(.sqlite(), as: .sqlite)
    app.migrations.add(AddAction())

    // Run migrations at app startup.
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
