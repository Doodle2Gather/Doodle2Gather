import Vapor
import Fluent
import DTSharedLibrary

extension WSRoomController {

    // MARK: - exitRoom

    func handleExitRoom(_ id: UUID) {
        self.logger.info("\(id) exit room")
        self.lock.withLockVoid {
            self.sockets[id] = nil
        }
        self.usersLock.withLockVoid {
            if let leavingUser = self.users[id],
               let userId = leavingUser.id {
                self.users = self.users.filter {
                    $0.value.id != userId
                }
                self.uuidStore[userId] = nil
            }
        }
        self.videoOnLock.withLockVoid {
            self.isVideoOn[id] = nil
        }
        self.logger.info("users in room \(Array(self.users.values))")
        syncData()
    }

    // MARK: - initiateAction

    func handleNewAction(_ ws: WebSocket, _ id: UUID,
                         _ message: DTInitiateActionMessage) {
        let action = message.action

        //        self.logger.info("\(action)")
        // action successful
        if let dispatchAction = roomController.process(action) {
            self.dispatchActionToPeers(
                dispatchAction, id: id, to: self.getAllWebSocketOptionsExcept(id),
                success: true, message: "New Action"
            )
            self.sendActionFeedback(
                originalAction: action,
                dispatchAction: dispatchAction, id: id,
                to: .id(id), success: true, message: "Action sucessful."
            )
            return
        }

        // action denied
        self.handleDoodleFetching(ws, id)
        self.sendActionFeedback(
            originalAction: action,
            dispatchAction: nil, id: id,
            to: .id(id), success: false, message: "Action failed. Please refetch"
        )
    }

    func dispatchActionToPeers(_ action: DTAdaptedAction, id: UUID, to sendOptions: [WebSocketSendOption],
                               success: Bool = true, message: String = "") {
        self.logger.info("Dispatched an action to peers!")
        let message = DTDispatchActionMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            action: action
        )

        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    func sendActionFeedback(originalAction: DTAdaptedAction, dispatchAction: DTAdaptedAction?,
                            id: UUID, to sendOption: WebSocketSendOption,
                            success: Bool = true, message: String = "",
                            isActionDenied: Bool = false) {
        let message = DTActionFeedbackMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            originalAction: originalAction,
            dispatchedAction: dispatchAction
        )
        let sendOptions = [sendOption]
        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    // MARK: - requestFetch

    func handleDoodleFetching(_ ws: WebSocket, _ id: UUID) {
        if !roomController.hasFetchedDoodles {
            PersistedDTRoom.getAllDoodles(roomId, on: self.db)
                .flatMapThrowing { $0.map(DTAdaptedDoodle.init) }
                .whenComplete { res in
                    switch res {
                    case .failure(let err):
                        self.logger.report(error: err)

                    case .success(let doodles):
                        self.logger.info("Fetching existing doodles.")
                        self.sendFetchedDoodles(doodles, id, to: [.socket(ws)])
                    }
                }
        } else {
            self.sendFetchedDoodles(roomController.doodleArray, id, to: [.socket(ws)])
        }
    }

    func sendFetchedDoodles(_ doodles: [DTAdaptedDoodle], _ id: UUID,
                            to sendOptions: [WebSocketSendOption],
                            success: Bool = true, message: String = "") {
        self.logger.info("Fetched doodles!")
        let message = DTFetchDoodleMessage(
            id: id, roomId: roomId,
            success: success,
            message: message,
            doodles: doodles
        )
        getWebSockets(sendOptions).forEach {
            $0.send(message: message)
        }
    }

    // MARK: - addDoodle & removeDoodle

    func handleAddDoodle(_ ws: WebSocket, _ id: UUID, _ createDoodleData: DTAdaptedDoodle.CreateRequest) {

        PersistedDTDoodle.createDoodle(createDoodleData, on: self.db)
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success(let doodle):
                    self.logger.info("Dispatched an add doodle action to peers!")
                    self.roomController.addDoodle(doodle)
                    let message = DTAddDoodleMessage(id: id, roomId: self.roomId, newDoodle: doodle)
                    self.getWebSockets(self.getAllWebSocketOptions).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

    func handleRemoveDoodle(_ ws: WebSocket, _ id: UUID, doodleId: UUID) {
        PersistedDTDoodle.removeDoodle(doodleId, on: db)
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success:
                    self.logger.info("Dispatched an remove doodle action to peers!")
                    self.roomController.removeDoodle(doodleId)
                    let message = DTRemoveDoodleMessage(id: id, roomId: self.roomId, doodleId: doodleId)
                    self.getWebSockets(self.getAllWebSocketOptions).forEach {
                        $0.send(message: message)
                    }
                }
            }
    }

    // MARK: - clearDrawing

    func handleClearDrawing(_ ws: WebSocket, _ id: UUID, _ message: DTClearDrawingMessage) {
        PersistedDTAction.query(on: self.db).delete().whenComplete { res in
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
            case .success:
                self.logger.info("Dispatched a clear action to peers!")
                self.getWebSockets(self.getAllWebSocketOptionsExcept(id)).forEach {
                    $0.send(message: message)
                }
            }
        }
    }

    func handleUpdateVideoState(id: UUID, isVideoOn: Bool) {
        self.videoOnLock.withLockVoid {
            self.isVideoOn[id] = isVideoOn
        }
    }
}
