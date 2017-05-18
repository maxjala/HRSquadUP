//
//  ChatTableViewCell.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "ChatTableViewCell"
    static let cellNib = UINib(nibName: ChatTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    
    @IBOutlet weak var chatTextView: UITextView!
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.layer.masksToBounds = true

        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
