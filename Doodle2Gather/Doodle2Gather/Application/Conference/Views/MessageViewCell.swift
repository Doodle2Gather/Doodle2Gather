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
    @IBOutlet private var rightUserLabel: UILabel!
    @IBOutlet private var rightContentLabel: UILabel!

    @IBOutlet private var rightUserBgView: UIView!
    @IBOutlet private var rightContentBgView: UIView!
    @IBOutlet private var leftUserBgView: UIView!
    @IBOutlet private var leftContentBgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        rightUserBgView.layer.cornerRadius = 20
        rightContentBgView.layer.cornerRadius = 10

        leftUserBgView.layer.cornerRadius = 20
        leftContentBgView.layer.cornerRadius = 10
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

    private var type: CellType = .right {
        didSet {
            if type == .right {
                leftUserLabel.isHidden = true
                leftContentLabel.isHidden = true
                leftUserBgView.isHidden = true
                leftContentBgView.isHidden = true
                rightUserLabel.isHidden = false
                rightContentLabel.isHidden = false
                rightUserBgView.isHidden = false
                rightContentBgView.isHidden = false
            } else {
                rightUserLabel.isHidden = true
                rightContentLabel.isHidden = true
                rightUserBgView.isHidden = true
                rightContentBgView.isHidden = true
                leftUserLabel.isHidden = false
                leftContentLabel.isHidden = false
                leftUserBgView.isHidden = false
                leftContentBgView.isHidden = false
            }
        }
    }

    func update(type: CellType, message: Message) {
        self.type = type
        self.user = message.userId
        self.content = message.text
    }
}
