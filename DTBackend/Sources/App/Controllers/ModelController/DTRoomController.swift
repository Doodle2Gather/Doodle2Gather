import Fluent
import Vapor
import DTSharedLibrary

private struct DTRoomCreationRequest: Codable {
    var name: String
    var createdBy: String
}

struct DTRoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Room.createRoom, use: createRoomHandler)
    }

    func createRoomHandler(req: Request) throws -> EventLoopFuture<PersistedDTRoom> {
        let newDTRoomRequest = try req.content.decode(DTRoomCreationRequest.self)
        let newDTRoom = PersistedDTRoom(name: newDTRoomRequest.name,
                                        createdBy: newDTRoomRequest.createdBy)
        return newDTRoom.save(on: req.db).map { newDTRoom }
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
