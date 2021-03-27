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

    @IBOutlet private var leftUserBgView: UIView!
    @IBOutlet private var leftContentBgView: UIView!
    @IBOutlet private var rightUserBgView: UIView!
    @IBOutlet private var rightContentBgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        leftUserBgView.layer.cornerRadius = leftUserBgView.frame.width / 2
        rightUserBgView.layer.cornerRadius = rightUserBgView.frame.width / 2

        rightContentBgView.layer.cornerRadius = 10
        leftContentBgView.layer.cornerRadius = 10
    }

    private var type: CellType = .right {
        didSet {
            let rightHidden = type == .left ? true : false

            rightUserLabel.isHidden = rightHidden
            rightContentLabel.isHidden = rightHidden

            leftUserLabel.isHidden = !rightHidden
            leftContentLabel.isHidden = !rightHidden

            rightUserBgView.isHidden = rightHidden
            rightContentBgView.isHidden = rightHidden

            leftUserBgView.isHidden = !rightHidden
            leftContentBgView.isHidden = !rightHidden
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
        self.user = message.userId
        self.content = message.text
        self.type = type
    }
}
