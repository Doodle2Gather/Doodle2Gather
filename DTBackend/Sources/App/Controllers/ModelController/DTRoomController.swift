import Fluent
import Vapor
import DTSharedLibrary

struct DTRoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

    }

    // TODO: - Change return types to Adapted Models instead

//    func getSingleHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
//
//    }
//    
//    func getAllHandler(req: Request) throws -> EventLoopFuture<[PersistedDTRoom]> {
//
//    }
//    
//    func createHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
//
//    }
//    
//    func deleteHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
//
//    }
//    
//    func addDoodleHandler(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
//
//    }
}

// MARK: - Queries

extension PersistedDTRoom {

    static func getSingleByID(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<PersistedDTRoom> {
      guard let id = id else {
        return db.eventLoop.makeFailedFuture(DTError.unableToRetreiveID(type: "PersistedDTRoom"))
      }
      return PersistedDTRoom.query(on: db)
        .filter(\.$id == id)
        .with(\.$doodles)
        .first()
        .unwrap(or: DTError.modelNotFound(type: "PersistedDTRoom", id: id.uuidString))
    }

    static func getAllDoodles(_ id: PersistedDTRoom.IDValue?, on db: Database) -> EventLoopFuture<[PersistedDTDoodle]> {
        getSingleByID(id, on: db)
            .flatMapThrowing { $0.doodles }
    }

    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTRoom]> {
        PersistedDTRoom.query(on: db)
            .with(\.$doodles)
            .all()
    }
}
