import UIKit
import AgoraRtmKit
import DTSharedLibrary

/**
 Engine that interfaces with Agora.
 */
class AgoraChatEngine: NSObject, ChatEngine {

    weak var delegate: ChatEngineDelegate?
    var agoraRtmKit: AgoraRtmKit?
    var rtmChannel: AgoraRtmChannel?
    private var chatID: UInt = 0
    private var currentUser: DTUser? = DTAuth.user

    func initialize() {
        agoraRtmKit = AgoraRtmKit(appId: ConferenceConstants.appID, delegate: self)
        agoraRtmKit?.agoraRtmDelegate = self
    }

    func tearDown() {
        agoraRtmKit?.logout(completion: nil)
    }

    private func getAgoraTokenAndJoinChannel(channelName: String) {
        guard let user = currentUser else {
            DTLogger.error("Error with fetching current user's uid")
            return
        }
        let url = URL(string: "\(ApiEndpoints.AgoraRtmTokenServer)?account=\(user.uid)")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                DTLogger.error("Error with fetching Agora token \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DTLogger.error("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data,
               let tokenResponse = try? JSONDecoder().decode(AgoraTokenAPIResponse.self, from: data) {
                self.agoraRtmKit?.login(byToken: tokenResponse.key,
                                        user: user.uid) { errorCode in
                    guard errorCode == .ok else {
                        DTLogger.error("Error with logging in to Agora server: code \(errorCode.rawValue)")
                        return
                    }
                    self.createOrJoinChannel(channelName: channelName)
                }
            }

        })
        task.resume()
    }

    func joinChannel(channelName: String) {
        getAgoraTokenAndJoinChannel(channelName: channelName)
    }

    private func createOrJoinChannel(channelName: String) {
        guard let rtmChannel = agoraRtmKit?.createChannel(withId: channelName, delegate: self) else {
            DTLogger.error("Unable to create or attach to chat channel: \(channelName)")
            return
        }
        rtmChannel.join { error in
            if error != .channelErrorOk {
                DTLogger.error("Unable to join chat channel: \(channelName)")
                return
            }
        }
        self.rtmChannel = rtmChannel
    }

    func leaveChannel() {
        rtmChannel?.leave { error in
            DTLogger.error("Leave chat channel error: code \(error.rawValue)")
        }
    }

    func send(message: String) {
        guard let user = currentUser else {
            return
        }
        let packet = "\(user.displayName.count) \(user.displayName)" + message
        let rtmMessage = AgoraRtmMessage(text: packet)

        rtmChannel?.send(rtmMessage) { errorCode in
            if errorCode != .errorOk {
                DTLogger.error("Error sending the message: code \(errorCode.rawValue)")
            } else {
                DTLogger.event("Successfully sent message from \(user.displayName): \(message)")
                self.delegate?.deliverMessage(from: user.uid, message: rtmMessage.text)
            }
        }
    }

}

// MARK: - AgoraRtmDelegate

extension AgoraChatEngine: AgoraRtmDelegate {

    func rtmKit(_ kit: AgoraRtmKit,
                connectionStateChanged state: AgoraRtmConnectionState,
                reason: AgoraRtmConnectionChangeReason) {
        DTLogger.info("Connection state changed: code \(state.rawValue)")
    }

    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        delegate?.deliverMessage(from: peerId, message: message.text)
    }

}

// MARK: - AgoraRtmChannelDelegate

extension AgoraChatEngine: AgoraRtmChannelDelegate {

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        DTLogger.event("Chat engine: \(member.userId) join")
    }

    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        DTLogger.event("Chat engine: \(member.userId) left")
    }

    func channel(_ channel: AgoraRtmChannel,
                 messageReceived message: AgoraRtmMessage,
                 from member: AgoraRtmMember) {
        DTLogger.event("Received message from userId \(member.userId): \(message.text)")
        delegate?.deliverMessage(from: member.userId, message: message.text)
    }

}
