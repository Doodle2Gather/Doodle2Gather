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
    var account: String = UIDevice.current.name

    func initialize() {
        agoraRtmKit = AgoraRtmKit(appId: RtcConstants.appID, delegate: self)
    }

    private func getAgoraTokenAndJoinChannel(channelName: String) {
        let url = URL(string: "\(ApiEndpoints.AgoraTokenServer)?uid=\(chatID)&channel=\(channelName)")!

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
             let tokenResponse = try? JSONDecoder().decode(AgoraTokenAPIResponse.self, from: data) {
            self.agoraRtmKit?.login(byToken: tokenResponse.token,
                                    user: self.account) { errorCode in
                guard errorCode == .ok else {
                    print("Error with logging in to Agora server")
                    return
                }
                self.joinChannel(channelName: "testing")
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

    }
}

extension AgoraChatEngine: AgoraRtmDelegate {

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
        delegate?.deliverMessage(from: member.userId, message: message.text)
    }
}
