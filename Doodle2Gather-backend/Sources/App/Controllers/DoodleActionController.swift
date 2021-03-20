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
        routes.webSocket("socket", onUpgrade: self.webSocket)
        routes.get(use: index)
        //    routes.post(":questionId", "answer", use: answer)
    }
    
    func webSocket(req: Request, socket: WebSocket) {
        self.wsController.connect(socket)
    }
    
    
    struct DoodleActionContext: Encodable {
        let actions: [DoodleAction]
    }
    
    func index(req: Request) throws -> EventLoopFuture<View> {
        // 1
        DoodleAction.query(on: req.db).all().flatMap {
            // 2
            return req.view.render("actions", DoodleActionContext(actions: $0))
        }
    }
    
//    func answer(req: Request) throws -> EventLoopFuture<Response> {
//        // 1
//        guard let questionId = req.parameters.get("questionId"), let questionUid = UUID(questionId) else {
//            throw Abort(.badRequest)
//        }
//        // 2
//        return Question.find(questionUid, on: req.db).unwrap(or: Abort(.notFound)).flatMap { question in
//            question.answered = true
//            // 3
//            return question.save(on: req.db).flatMapThrowing {
//                // 4
//                try self.wsController.send(message: QuestionAnsweredMessage(questionId: question.requireID()), to: .id(question.askedFrom))
//                // 5
//                return req.redirect(to: "/")
//            }
//        }
//    }
}
