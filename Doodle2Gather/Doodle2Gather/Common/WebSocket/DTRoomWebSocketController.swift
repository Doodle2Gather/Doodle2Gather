import Foundation
import DTSharedLibrary

final class DTRoomWebSocketController: DTSendableWebSocketSubController {

    weak var delegate: DTRoomWebSocketControllerDelegate?
    weak var conferenceDelegate: DTConferenceWebSocketControllerDelegate?

    var parentController: DTWebSocketController?
    var handledMessageType = DTMessageType.room
    var id: UUID?

    private let decoder = JSONDecoder()
    var roomId: UUID?

    func handleMessage(_ data: Data) {
        do {
            let message = try decoder.decode(DTRoomMessage.self, from: data)
            DTLogger.event { "Received message: \(message.subtype)" }
            switch message.subtype {
            case .actionFeedback:
                try self.handleActionFeedback(data)
            case .dispatchAction:
                try self.handleDispatchedAction(data)
            case .fetchDoodle:
                try self.handleFetchDoodle(data)
            case .addDoodle:
                try self.handleAddDoodle(data)
            case .removeDoodle:
                try self.handleRemoveDoodle(data)
            case .participantInfo:
                try self.handleParticipantInfo(data)
            case .updateLiveState:
                try self.handleUpdateLiveState(data)
            case .usersConferenceState:
                try self.handleUpdateUsersConferenceState(data)
            default:
                break
            }
        } catch {
            DTLogger.error(error.localizedDescription)
        }
    }

    func handleActionFeedback(_ data: Data) throws {
        // TODO: yet to be tested.
        let feedback = try decoder.decode(DTActionFeedbackMessage.self, from: data)
        DispatchQueue.main.async {
            if !feedback.success {
                DTLogger.error(feedback.message)
                return
            }
        }
    }

    func handleDispatchedAction(_ data: Data) throws {
        let dispatch = try decoder.decode(DTDispatchActionMessage.self, from: data)
        DispatchQueue.main.async {
            // TODO: refactor unhappy path to be at the top
            if dispatch.success {
                self.delegate?.dispatchAction(dispatch.action)
            } else {
                DTLogger.error(dispatch.message)
            }
        }
    }

    func handleFetchDoodle(_ data: Data) throws {
        let fetch = try decoder.decode(DTFetchDoodleMessage.self, from: data)
        DispatchQueue.main.async {
            self.delegate?.loadDoodles(fetch.doodles.map { DTDoodleWrapper(doodle: $0) })
        }
    }

    func handleAddDoodle(_ data: Data) throws {
        // receive a message from backend to add doodle
        let fetch = try decoder.decode(DTAddDoodleMessage.self, from: data)
        DispatchQueue.main.async {
             self.delegate?.addNewDoodle(DTDoodleWrapper(doodle: fetch.newDoodle))
        }
    }

    func handleParticipantInfo(_ data: Data) throws {
        let fetch = try decoder.decode(DTParticipantInfoMessage.self, from: data)
        DTLogger.info { "Fetched participant info: \(fetch.users)" }
        delegate?.fetchUserAccesses(fetch.users)
    }

    func handleRemoveDoodle(_ data: Data) throws {
        // receive a message from backend to remove doodle
        let fetch = try decoder.decode(DTRemoveDoodleMessage.self, from: data)
        DispatchQueue.main.async {
             self.delegate?.removeDoodle(doodleId: fetch.doodleId)
        }
    }

    func handleUpdateLiveState(_ data: Data) throws {
        let newState = try decoder.decode(DTRoomLiveStateMessage.self, from: data)
        let newUsersInRoom = newState.usersInRoom
        DTLogger.debug { "Users in room: \(newUsersInRoom.map { $0.displayName })" }
        delegate?.updateUsers(newUsersInRoom)
    }

    func handleUpdateUsersConferenceState(_ data: Data) throws {
        let newState = try decoder.decode(DTUsersConferenceStateMessage.self, from: data)
        let newConferenceState = newState.conferenceState
        DTLogger.debug { "New conference state: " +
            "\(newConferenceState.map { "\($0.displayName): \($0.isVideoOn) \($0.isAudioOn)" }.joined(separator: ", "))"
        }
        conferenceDelegate?.updateStates(newConferenceState)
    }
}

// MARK: - SocketController

extension DTRoomWebSocketController: RoomSocketController {

    func joinRoom(roomId: UUID) {
        guard let id = self.id,
              let userId = DTAuth.user?.uid else {
            return
        }
        DTLogger.info("Joining room")

        let message = DTJoinRoomMessage(id: id, userId: userId, roomId: roomId)
        send(message)
    }

    func addAction(_ action: DTAdaptedAction) {
        guard let id = self.id else {
            return
        }
        DTLogger.info("Adding action")

        let message = DTInitiateActionMessage(
            actionType: action.type, entities: action.entities,
            id: id, userId: DTAuth.user!.uid, roomId: action.roomId, doodleId: action.doodleId
        )

        send(message)
    }

    func refetchDoodles() {
        // Send a request to backend to send back a DTFetchDoodleMessage
        guard let id = self.id else {
            return
        }
        DTLogger.info("Request fetching doodles.")

        let message = DTRequestFetchMessage(id: id, roomId: roomId!)
        send(message)
    }

    func addDoodle() {
        // Send a request to backend to send back a DTAddDoodleMessage
        guard let id = self.id else {
            return
        }
        DTLogger.info("Request add doodle.")

        let message = DTRequestAddDoodleMessage(id: id, roomId: roomId!)
        send(message)
    }

    func removeDoodle(doodleId: UUID) {
        // Send a request to backend to send back a DTRemoveDoodleMessage
        guard let id = self.id else {
            return
        }
        DTLogger.info("Request remove doodle.")

        let message = DTRemoveDoodleMessage(id: id, roomId: roomId!, doodleId: doodleId)
        send(message)
    }

    func exitRoom() {
        guard let id = self.id,
              let roomId = self.roomId else {
            return
        }
        DTLogger.info("Leaving room. Disconnecting ...")
        let message = DTExitRoomMessage(id: id, roomId: roomId)
        send(message)
    }

    func updateConferencingState(isVideoOn: Bool, isAudioOn: Bool) {
        guard let id = self.id,
              let roomId = self.roomId else {
            return
        }
        DTLogger.info("Sending video state to backend, isVideoOn: \(isVideoOn)")
        let message = DTUpdateUserConferencingStateMessage(id: id,
                                                           roomId: roomId,
                                                           isVideoOn: isVideoOn,
                                                           isAudioOn: isAudioOn)
        send(message)
    }
}
