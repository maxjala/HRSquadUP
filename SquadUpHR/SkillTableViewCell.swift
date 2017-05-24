//
//  SkillTableViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

protocol SkillTableViewCellDelegate {
    func sendEmailTapped(_ employee: Employee, skill: Skill)
}

class SkillTableViewCell: UITableViewCell {
    
    @IBOutlet weak var skillLabel: UILabel!
    
    @IBOutlet weak var requestMentorButton: UIButton! {
        didSet {
            requestMentorButton.addTarget(self, action: #selector(sendbutton), for: .touchUpInside)
        }
    }
    
    var delegate : SkillTableViewCellDelegate?
    var employee : Employee?
    var skill : Skill?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sendbutton(){
        if delegate != nil {
            if let _employee = employee,
                let _skill = skill {
                delegate?.sendEmailTapped(_employee, skill: _skill)
            }
        }
    }
    
}
