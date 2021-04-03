import Fluent
import Vapor
import DoodlingAdaptedLibrary

struct DTActionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(Endpoints.Action.getAll, use: getAllHandler)
        routes.on(Endpoints.Action.getRoomAll, use: getRoomAllHandler)
    }
    
    func getAllHandler(req: Request) -> EventLoopFuture<[DTAdaptedAction]> {
        PersistedDTAction.getAll(on: req.db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedAction.init)
            }
    }
    
    func getRoomAllHandler(req: Request) throws -> EventLoopFuture<[DTAdaptedAction]> {
        let roomId = try req.requireUUID(parameterName: "roomId")
        
        return PersistedDTAction.getRoomAll(roomId, on: req.db)
            .flatMapThrowing { actions in
                actions.map(DTAdaptedAction.init)
            }
    }
    
//    func createHandler(req: Request) throws -> EventLoopFuture<DTAdaptedAction> {
//      let action = try req.content.decode(DTAdaptedAction.self)
//
//        return createAction(with: action, req: req)
//        .flatMap { PersistedDTAction.getSingleByID(category.id, on: req.db) }
//        .flatMapThrowing(DTAdaptedAction.init)
//    }
//
//    func createAction(with action: DTAdaptedAction, req: Request) -> EventLoopFuture<Void> {
//        let persisted = action.makePersistedAction()
//
//        return persisted.save(on:req.db)
//    }
}

// MARK: - Queries

extension PersistedDTAction {
//    static func getSingleByID(_ id: PersistedDTAction.IDValue?, on database: Database) -> EventLoopFuture<PersistedDTAction> {
//      guard let id = id else {
//        return database.eventLoop.makeFailedFuture(TILError.unableToRetreiveID(type: "Category"))
//      }
//      return PersistedDTAction.find(id, on: database)
//        .unwrap(or: TILError.modelNotFound(type: "PersistedDTAction", id: id.uuidString))
//    }
    
    static func getRoomAll(_ roomId: UUID, on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db)
            .filter(\.$roomId == roomId)
            .all()
    }
    
    static func getAll(on db: Database) -> EventLoopFuture<[PersistedDTAction]> {
        PersistedDTAction.query(on: db).all()
    }
}
