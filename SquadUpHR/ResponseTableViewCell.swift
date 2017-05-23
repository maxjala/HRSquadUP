//
//  ResponseTableViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 23/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ResponseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    static let cellIdentifier = "ResponseTableViewCell"
    static let cellNib = UINib(nibName: ResponseTableViewCell.cellIdentifier, bundle: Bundle.main)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
