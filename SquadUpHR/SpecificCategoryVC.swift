//
//  SpecificCategoryVC.swift
//  SquadUpHR
//
//  Created by Max Jala on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import MessageUI

enum DisplayType {
    case companySkills
    case userSkills
}

class SpecificCategoryVC: UIViewController {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    @IBOutlet weak var accentView: UIView! {
        didSet {
            accentView.layer.shadowRadius = 10
            accentView.layer.shadowOpacity = 0.2
            accentView.layer.shadowOffset = CGSize(width: 5, height: 10)
            
            accentView.clipsToBounds = false
        }
    }
    
    var category : SkillCategory?
    var selectedUser : Employee?
    var skills: [Skill] = []
    var displayType : DisplayType = .companySkills
    var enableContinue = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchSkills()
        categoryLabel.text = category?.title
        accentView.backgroundColor = category?.color
        
        configureDisplayType(displayType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden()

    }
    
    func configureDisplayType (_ type : DisplayType) {
        switch type {
        case .companySkills :
            enableContinue = true
            
            configureCompany()
        case .userSkills:
            
            configureUser()
            enableContinue = false
            break
            
        }
    }
    
    func configureUser() {
        guard let skils = category?.skills else {return}
        skills = []
        skills = skils
        
    }
    
    func configureCompany() {
        fetchCompanySkills()
        
    }
    
    func fetchCompanySkills() {
        JSONConverter.getJSONResponse("users/skills") { (skills, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            
            self.createCategorySkills(skills!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func createCategorySkills(_ json: [[String : Any]]) {
        skills = []
        for each in json {
            if let skill = each["skill_name"] as? String,
                let cat = each["category"] as? String {
                if cat == category?.title {
                    let newSkill = Skill(aSkill: skill, aSkillCategory: cat)
                    skills.append(newSkill)
                }
            }
            
        }
    }
    
}

extension SpecificCategoryVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell") as? SkillTableViewCell else {return UITableViewCell()}
        //cell.skillLabel.text = skills[indexPath.row]
        //cell.skillLabel.textColor = category?.color
        //cell.skillLabel.alpha = 0.8
        
        cell.skillLabel.text = skills[indexPath.row].skillName
        
        if enableContinue == true {
            cell.delegate = self
            cell.employee = selectedUser
            cell.skill = skills[indexPath.row]
        }
        
        return cell
        
    }
}

extension SpecificCategoryVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BrowseTutorVC") as? BrowseTutorVC else {return}
        
        if enableContinue == true {
            vc.skill = skills[indexPath.row]
            vc.viewType = .specificSkill
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
}

extension SpecificCategoryVC : MFMailComposeViewControllerDelegate {
    func sendEmail(_ employee: Employee, skill: Skill) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([employee.email])
            mail.setSubject("\(skill.skillName) mentorship request")
            mail.setMessageBody("Hey Friend! I am requesting mentorship through SquadUp!", isHTML: false)
            //selectedMentor = employee
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            sendMentorRequest((selectedUser?.employeeID)!)
        default:
            sendMentorRequest((selectedUser?.employeeID)!)
        }
        
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func sendMentorRequest(_ mentorID: Int) {
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        let responseJSON : [String:Any]
        responseJSON = ["mentor_id" : mentorID, "mentee_message" : "Please help mentor me :)"]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: responseJSON, options: []) {
            
            let url = URL(string: "http://192.168.1.114:3000/api/v1/mentorships/create_mentor?private_token=\(validToken)")
            var urlRequest = URLRequest(url: url!)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = jsonData
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let validError = error as NSError? {
                    print(validError.localizedDescription)
                    return
                }
                
            }
            
            dataTask.resume()
        }
    }
    
    
}





extension SpecificCategoryVC: SkillTableViewCellDelegate {
    func sendEmailTapped(_ employee: Employee, skill: Skill) {
        sendEmail(employee, skill: skill)
    }
}




