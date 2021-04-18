//
//  UserViewCell.swift
//  Doodle2Gather
//
//  Created by Wang on 18/4/21.
//

import UIKit

class UserViewCell: UITableViewCell {
    @IBOutlet var userIconLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
