//
//  SkillsTableViewCell.swift
//  SquadUpHR
//
//  Created by nicholaslee on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class SkillsTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "SkillsTableViewCell"
    static let cellNib = UINib(nibName: SkillsTableViewCell.cellIdentifier, bundle: Bundle.main)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
