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
    func sendEmailTapped()
}

class EmployeeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    static let cellIdentifier = "EmployeeTableViewCell"
    static let cellNib = UINib(nibName: EmployeeTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    var delegate : SendEmailDelegate?
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
        delegate?.sendEmailTapped()
    }
    
    
}

//extension EmployeeTableViewCell: MFMailComposeViewControllerDelegate {
//    func sendEmail() {
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients(["maxjala@gmail.com"])
//            mail.setMessageBody("<p>Hey Friend! I am requesting mentorship through SquadUp!</p>", isHTML: true)
//        
//            present(mail, animated: true)
//        } else {
//            // show failure alert
//        }
//    }
//    
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        
//        
//        controller.dismiss(animated: true, completion: nil)
//        
//    }
//}
