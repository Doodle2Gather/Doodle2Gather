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
    @IBOutlet private var rightUserLabel: UILabel!
    @IBOutlet private var rightContentLabel: UILabel!
    @IBOutlet private var leftUserLabel: UILabel!
    @IBOutlet private var leftContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private var type: CellType = .right {
        didSet {
            let rightHidden = type == .left ? true : false

            rightUserLabel.isHidden = rightHidden
            rightContentLabel.isHidden = rightHidden

            leftUserLabel.isHidden = !rightHidden
            leftContentLabel.isHidden = !rightHidden
        }
    }

    private var user: String? {
        didSet {
            switch type {
            case .left:
                leftUserLabel.text = user
            case .right:
                rightUserLabel.text = user
            }
        }
    }

    private var content: String? {
        didSet {
            switch type {
            case .left:
                leftContentLabel.text = content
            case .right:
                rightContentLabel.text = content
            }
        }
    }

    func update(type: CellType, message: Message) {
        self.type = type
        self.user = message.userId
        self.content = message.text
    }
}
