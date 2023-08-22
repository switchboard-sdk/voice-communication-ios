//
//  UserListTableViewCell.swift
//  DuckingAndSoundEffectsApp
//
//  Created by Iván Nádor on 2023. 08. 18..
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
