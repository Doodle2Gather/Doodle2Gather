//
//  AgoraChatEngine.swift
//  Doodle2Gather
//
//  Created by Wang on 24/3/21.
//

import UIKit
import AgoraRtmKit

/**
 Engine that interfaces with Agora.
 */
class AgoraChatEngine: NSObject, ChatEngine {
    weak var delegate: ChatEngineDelegate?
    var agoraRtmKit: AgoraRtmKit?
    var rtmChannel: AgoraRtmChannel?
    private var chatID: UInt = 0
    var account: String = ConferenceConstants.testUser

    func initialize() {
        agoraRtmKit = AgoraRtmKit(appId: ConferenceConstants.appID, delegate: self)
        agoraRtmKit?.agoraRtmDelegate = self
        getAgoraTokenAndJoinChannel(channelName: "messaging")
    }

    // Currently reusing the logic for video, need to change to rtm
    private func getAgoraTokenAndJoinChannel(channelName: String) {
        let url = URL(string: "\(ApiEndpoints.AgoraRtmTokenServer)?account=\(account)")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
          if let error = error {
            print("Error with fetching Agora token \(error)")
            return
          }

          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(String(describing: response))")
            return
          }

          if let data = data,
             let tokenResponse = try? JSONDecoder().decode(AgoraRtmTokenResponse.self, from: data) {
            // TODO: CHange "username" to when authentication is done
            // Also, the username cannot contain special characters
            self.agoraRtmKit?.login(byToken: tokenResponse.key,
                                    user: self.account) { errorCode in
                guard errorCode == .ok else {
                    print("Error with logging in to Agora server: code \(errorCode.rawValue)")
                    return
                }
                self.joinChannel(channelName: channelName)
            }
          }

        })
        task.resume()
    }

    func joinChannel(channelName: String) {
        guard let rtmChannel = agoraRtmKit?.createChannel(withId: channelName, delegate: self) else {
            print("Unable to create or attach to channel: \(channelName)")
            return
        }
        rtmChannel.join { error in
            if error != .channelErrorOk {
                print("Unable to join channel")
                return
            }
        }
        self.rtmChannel = rtmChannel
    }

    func leaveChannel() {
        rtmChannel?.leave { error in
            print("Leave channel error: \(error.rawValue)")
        }
    }

    func send(message: String) {
        let rtmMessage = AgoraRtmMessage(text: message)
        rtmChannel?.send(rtmMessage) { errorCode in
            if errorCode != .errorOk {
                print("Error sending the message: code \(errorCode.rawValue)")
            } else {
                self.delegate?.deliverMessage(from: self.account, message: message)
            }
        }
    }
}

extension AgoraChatEngine: AgoraRtmDelegate {
    func rtmKit(_ kit: AgoraRtmKit,
                connectionStateChanged state: AgoraRtmConnectionState,
                reason: AgoraRtmConnectionChangeReason) {
        print("Connection state changed: \(state)")
    }

    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        delegate?.deliverMessage(from: peerId, message: message.text)
    }
}

// MARK: - AgoraRtmChannelDelegate

extension AgoraChatEngine: AgoraRtmChannelDelegate {
    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        DispatchQueue.main.async {
            print("\(member.userId) join")
        }
    }

    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        DispatchQueue.main.async {
            print("\(member.userId) left")
        }
    }

    func channel(_ channel: AgoraRtmChannel,
                 messageReceived message: AgoraRtmMessage,
                 from member: AgoraRtmMember) {
        print("Received from userId \(member.userId): \(message.text)")
        delegate?.deliverMessage(from: member.userId, message: message.text)
    }
}

private struct AgoraRtmTokenResponse: Codable {
    let key: String
}
