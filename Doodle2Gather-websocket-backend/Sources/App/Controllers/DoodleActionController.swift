//
//  DoodleActionController.swift
//  
//
//  Created by eksinyue on 17/3/21.
//

import Fluent
import Vapor

struct DoodleActionController: RouteCollection {
    let wsController: WebSocketController

    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("rooms", "devRoom", onUpgrade: self.webSocket)
        routes.get(use: index)
    }

    func webSocket(req: Request, socket: WebSocket) {
        self.wsController.connect(socket)
    }

    struct DoodleActionContext: Encodable {
        let actions: [DoodleAction]
    }

    func index(req: Request) throws -> EventLoopFuture<View> {
        DoodleAction.query(on: req.db).all().flatMap {
            return req.view.render("actions", DoodleActionContext(actions: $0))
        }
    }
}
