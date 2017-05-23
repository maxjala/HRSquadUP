//
//  InviteTableViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 22/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

protocol InviteViewCellDelegate {
    func sendAcceptToAPI(_ mentorship: Mentorship)
    func sendRejectToAPI(_ mentorship: Mentorship)
    
}

class InviteTableViewCell: UITableViewCell {
    
    var delegate : InviteViewCellDelegate? = nil
    var mentorship : Mentorship? {
        didSet {
            self.updateUI()
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var responseLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton! {
        didSet{
            acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var rejectButton: UIButton! {
        didSet{
            rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
            
        }
    }
    
    static let cellIdentifier = "InviteTableViewCell"
    static let cellNib = UINib(nibName: InviteTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateUI() {
        if let ment = mentorship {
            if ment.status == "accepted" {
                acceptButton.backgroundColor = .gray
                acceptButton.isEnabled = false
                rejectButton.isEnabled = true
                rejectButton.backgroundColor = UIColor(red: 255/255, green: 157/255, blue: 133/255, alpha: 1)
            } else if ment.status == "refused" {
                rejectButton.backgroundColor = .gray
                rejectButton.isEnabled = false
                acceptButton.isEnabled = true
                acceptButton.backgroundColor = UIColor(red: 177/255, green: 206/255, blue: 177/255, alpha: 1)
            }
        }
    }
    
    func acceptButtonTapped() {
        if delegate != nil {
            if let _mentorship = mentorship {
                delegate?.sendAcceptToAPI(_mentorship)
            }
        }
        
    }
    
    func rejectButtonTapped() {
        if delegate != nil {
            if let _mentorship = mentorship {
                delegate?.sendRejectToAPI(_mentorship)
            }
        }
        
    }
    
}
