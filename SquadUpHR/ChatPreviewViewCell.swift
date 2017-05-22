//
//  ChatPreviewViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 22/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ChatPreviewViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationView: UIView!
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
