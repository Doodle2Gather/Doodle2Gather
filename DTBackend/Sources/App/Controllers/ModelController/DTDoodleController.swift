import Fluent
import Vapor
import DTSharedLibrary

struct DTDoodleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

    }

    //TODO: - Change return types to Adapted Models instead
    
//    func getSingleHandler(req: Request) throws -> EventLoopFuture<PersistedDTDoodle> {
//
//    }
//    
//    func getAllHandler(req: Request) throws -> EventLoopFuture<[PersistedDTDoodle]> {
//
//    }
//    
//    func createHandler(req: Request) throws -> EventLoopFuture<PersistedDTDoodle> {
//
//    }
//    
//    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
//
//    }

}

// MARK: - Queries

extension PersistedDTDoodle {
    
    static func getSingleByID(_ id: PersistedDTDoodle.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTDoodle> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTDoodle"))
      }
      return PersistedDTDoodle.query(on: db)
        .filter(\.$id == id)
        .with(\.$actions)
        .with(\.$strokes)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTDoodle", id: id.uuidString))
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        PersistedDTDoodle.query(on: db)
            .with(\.$actions)
            .with(\.$strokes)
            .all()
    }
}
