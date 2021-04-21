import Vapor
import Fluent
import DTSharedLibrary

/// Handles all `DTRoomMessage` sent between the clients and the server
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
        self.conferenceLock.withLockVoid {
            self.conferenceState[id] = nil
        }
        self.logger.info("users in room \(Array(self.users.values))")
        syncData()
    }

    // MARK: - initiateAction

    /// Handles a new action received from a client
    func handleNewAction(_ ws: WebSocket, _ id: UUID,
                         _ message: DTInitiateActionMessage) {
        let action = message.action

        /// action successful
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

        /// action denied
        self.handleDoodleFetching(ws, id)
        self.sendActionFeedback(
            originalAction: action,
            dispatchAction: nil, id: id,
            to: .id(id), success: false, message: "Action failed. Please refetch"
        )
    }

    /// Dispatches a successful new action to all clients in the same room to reflect the changes
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

    /// Sends an feedback message to the initializer of the new action
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

    /// Handles when a client request a refetch
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

    /// Sends a refetch message containing current state of all doodles in a room to the client
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

    /// Adds a doodle to the room
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

    /// Removes a doodle from the room with the given doodle id
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

    // MARK: - updateVideoState

    /// Handles when a client update his/her conference state
    func handleUpdateConferenceState(id: UUID, isVideoOn: Bool, isAudioOn: Bool) {
        self.conferenceLock.withLockVoid {
            self.conferenceState[id] = (isVideoOn, isAudioOn)
        }
    }

    /// Handles when the owner of the room update participant's permission of the room
    func handleSetUserPermission(_ ws: WebSocket, _ message: DTSetUserPermissionsMessage) {
        PersistedDTUserAccesses
            .query(on: db)
            .with(\.$room)
            .with(\.$user, { $0.with(\.$accessibleRooms, { $0.with(\.$doodles, { $0.with(\.$entities) }) }) })
            .filter(\.$room.$id == message.roomId)
            .filter(\.$user.$id == message.userToSetId)
            .set(\.$canEdit, to: message.setCanEdit)
            .set(\.$canChat, to: message.setCanChat)
            .set(\.$canVideoConference, to: message.setCanVideoConference)
            .update()
            .whenComplete { res in
                switch res {
                case .failure(let err):
                    self.logger.report(error: err)
                case .success:
                    self.logger.info("Set permission successfully, dispatching new permissions")
                    self.updateParticipantsInfo()
                }
            }
    }

    /// Handles when a room timer is set
    func handleSetRoomTimer(_ ws: WebSocket, _ message: DTSetRoomTimerMessage) {
        self.getWebSockets(self.getAllWebSocketOptions).forEach {
            $0.send(message: message)
        }
    }
}
