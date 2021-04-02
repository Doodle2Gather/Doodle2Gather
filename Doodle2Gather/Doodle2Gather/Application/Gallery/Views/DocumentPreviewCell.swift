//
//  DocumentPreviewCell.swift
//  Doodle2Gather
//
//  Created by Wang on 2/4/21.
//

import UIKit

class DocumentPreviewCell: UICollectionViewCell {
    @IBOutlet private var roomNameLabel: UILabel!

    private var name: String = "" {
        didSet {
            roomNameLabel.text = name
        }
    }

    func setName(_ name: String) {
        self.name = name
    }
}
