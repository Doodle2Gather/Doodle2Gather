//
//  MessageViewCell.swift
//  Doodle2Gather
//
//  Created by Wang on 24/3/21.
//

import UIKit

enum CellType {
    case left, right
}

class MessageViewCell: UITableViewCell {
    @IBOutlet private var leftUserLabel: UILabel!
    @IBOutlet private var leftContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private var user: String? {
        didSet {
            leftUserLabel.text = user
        }
    }

    private var content: String? {
        didSet {
            leftContentLabel.text = content
        }
    }

    func update(type: CellType, message: Message) {
        self.user = message.userId
        self.content = message.text
    }
}
