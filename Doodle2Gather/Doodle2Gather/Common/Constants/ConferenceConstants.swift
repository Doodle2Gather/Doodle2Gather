//
//  ConferenceConstants.swift
//  Doodle2Gather
//
//  Created by Wang on 28/3/21.
//

import UIKit

struct ConferenceConstants {
    // General constants
    static let appID = "4bc7d320fa674c4bbba8abbfddbfd4d3"
    static let tempToken: String? = "0064bc7d320fa674c4bbba8abbfddbfd4d3IACl27eym7MDuUmqz+"
        + "zrfxn8CjDQsvfC/evpAZ9PxbntFAZa8+gAAAAAEAC5X9YG8BBXYAEAAQDwEFdg"
    static let testUser = "hi"

    // Video constants
    static let aspectRatio: CGFloat = 9 / 16

    // Chat constants
    static let placeholderText = "Type your message here..."
    static let defaultContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static let defaultNameLeftInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    static let defaultNameRightInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    static let messageInputBarInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

    static func messageInputBarOffsetCalculator(offset: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: offset + 40, right: 0)
    }
}
