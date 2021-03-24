//
//  AgoraChatEngine.swift
//  Doodle2Gather
//
//  Created by Wang on 24/3/21.
//

import Foundation
import AgoraRtmKit

/**
 Engine that interfaces with Agora.
 */
class AgoraChatEngine: NSObject, ChatEngine {
    weak var delegate: ChatEngineDelegate?
    var agoraRtm: AgoraRtmKit?
    private var chatID: UInt = 0

    func initialize() {
        agoraRtm = AgoraRtmKit(appId: RtcConstants.appID, delegate: self)
    }

    func joinChannel(channelName: String) {
        print("Haha")
    }

}

extension AgoraChatEngine: AgoraRtmDelegate {

}
