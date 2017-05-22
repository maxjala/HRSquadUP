//
//  EmployeeTableViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import MessageUI

protocol SendEmailDelegate {
    func sendEmailTapped(_ employee: Employee)
}

class EmployeeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    static let cellIdentifier = "EmployeeTableViewCell"
    static let cellNib = UINib(nibName: EmployeeTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    var delegate : SendEmailDelegate?
    var employee : Employee?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var sendEmailButton: UIButton! {
        didSet{
            sendEmailButton.addTarget(self, action: #selector(sendbutton), for: .touchUpInside)
        }
    }
    
    func sendbutton(){
        if delegate != nil {
            if let _employee = employee {
                delegate?.sendEmailTapped(_employee)
            }
        }
    }

    
}

