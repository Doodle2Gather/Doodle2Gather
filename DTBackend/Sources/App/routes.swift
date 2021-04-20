import Vapor
import DTSharedLibrary

func routes(_ app: Application) throws {

    try app.register(collection: WSConnectionController(db: app.db))

}
