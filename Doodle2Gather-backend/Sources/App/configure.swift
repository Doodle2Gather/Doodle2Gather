import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // Configure rendering engine
    //  app.views.use(.leaf)
    
    // Configure database
    app.databases.use(.sqlite(), as: .sqlite)
    app.migrations.add(AddAction())
    
    // Run migrations at app startup.
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}
