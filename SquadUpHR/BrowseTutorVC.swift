//
//  BrowseTutorVC.swift
//  SquadUpHR
//
//  Created by Max Jala on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import MessageUI

enum ViewType {
    case specificSkill
    case allUsers
    
}




class BrowseTutorVC: UIViewController {
    
    @IBOutlet weak var connectLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(EmployeeTableViewCell.cellNib, forCellReuseIdentifier: EmployeeTableViewCell.cellIdentifier)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 70
        }
    }
    
    @IBOutlet weak var accentView: UIView! {
        didSet {
            accentView.layer.shadowRadius = 5
            accentView.layer.shadowOpacity = 0.2
            accentView.layer.shadowOffset = CGSize(width: 0, height: 10)
            
            accentView.clipsToBounds = false
        }
    }

    var employees : [Employee] = []
    var skill: Skill?
    var viewType: ViewType = .allUsers
    var searchActive: Bool = false
    var filtered: [Employee] = []
    var canRequestMentor = false
    var selectedMentor : Employee?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewType(viewType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden()
    }

    
    func configureViewType(_ view: ViewType){
        switch view {
        case .allUsers:
            getAllCompanyUsers()
            connectLabel.text = "Connect"
        case .specificSkill:
            getEmployeesWithRelevantSkill()
            connectLabel.text = skill?.skillName
            canRequestMentor = true
            break
        }
    }
    
    func getAllCompanyUsers() {
        JSONConverter.getJSONResponse("users") { (workers, error) in
            if let validError = error {
                print(validError.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.employees = JSONConverter.createObjects(workers!) as! [Employee]
                self.filtered = self.employees
                self.tableView.reloadData()
            }
        }
        
    }
    
    func getEmployeesWithRelevantSkill(){
        JSONConverter.fetchAllUsers { (users, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let validUsers = users {
                DispatchQueue.main.async {
                    self.createFilteredEmployeeList(validUsers)
                    self.filtered = self.employees
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func createFilteredEmployeeList(_ userJSON: [Any]) {
        employees.removeAll()
        
        for each in userJSON {
            if let userInfo = each as? [String: Any],
                let id = userInfo["id"] as? Int,
                let jobTitle = userInfo["job_title"] as? String,
                let department = userInfo["department"] as? String,
                let firstName = userInfo["first_name"] as? String,
                let lastName = userInfo["last_name"] as? String,
                let email = userInfo["email"] as? String,
                let privateToken = userInfo["private_token"] as? String,
                let skillsArray = userInfo["skills_array"] as? [[String:Any]],
                let pictureURL = userInfo["profile_picture"] as? String {
                
                for aSkill in skillsArray {
                    if aSkill["skill_name"] as? String == skill?.skillName {
                        let aUser = Employee(anID: id, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken, aPictureURL: pictureURL)
                        
                        employees.append(aUser)
                    }
                }
                
            }
        }
    }

    
    
}



extension BrowseTutorVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeTableViewCell.cellIdentifier) as? EmployeeTableViewCell else {return UITableViewCell()}
        
        let employee = filtered[indexPath.row]
        
        if canRequestMentor == true {
            cell.sendEmailButton.isHidden = false
            cell.sendEmailButton.isEnabled = true
        }
        
        cell.delegate = self
        cell.employee = employee
        cell.skill = skill
        cell.nameLabel.text = employee.fullName
        cell.jobTitleLabel.text = employee.jobTitle
        cell.departmentLabel.text = employee.department
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: employee.pictureURL)
        
        return cell
    }
}

extension BrowseTutorVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
        
        controller.profileType = .otherProfile
        controller.selectedProfile = employees[indexPath.row]
        
        navigationController?.pushViewController(controller, animated: true)
        
    
    }
}

extension BrowseTutorVC: UISearchBarDelegate{
    // MARK: Search Bar Functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            filtered = employees;
            self.tableView.reloadData()
            return
        }
        
        filtered = employees.filter({ (employee) -> Bool in
            let nameString: NSString = employee.fullName as NSString
            let departString: NSString = employee.department as NSString
            let jobString: NSString = employee.jobTitle as NSString
            let range = nameString.range(of: searchText, options: .caseInsensitive)
            let departRange = departString.range(of: searchText, options: .caseInsensitive)
            let jobRange = jobString.range(of: searchText, options: .caseInsensitive)
            
            return range.location != NSNotFound || jobRange.location != NSNotFound || departRange.location != NSNotFound
          
        })
        
        self.tableView.reloadData()
    }

    
}

extension BrowseTutorVC : MFMailComposeViewControllerDelegate {
    func sendEmail(_ employee: Employee, skill: Skill) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([employee.email])
            mail.setSubject("\(skill.skillName) mentorship request")
            mail.setMessageBody("Hey Friend! I am requesting mentorship through SquadUp!", isHTML: false)
            selectedMentor = employee
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            sendMentorRequest((selectedMentor?.employeeID)!)
        default:
            sendMentorRequest((selectedMentor?.employeeID)!)
        }
        
        
        controller.dismiss(animated: true, completion: nil)
    
    }
    
    func sendMentorRequest(_ mentorID: Int) {
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        let responseJSON : [String:Any]
        responseJSON = ["mentor_id" : mentorID, "mentee_message" : "Please help mentor me :)", "skill_id": skill?.id]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: responseJSON, options: []) {
            
            let url = URL(string: "http://192.168.1.33:3000/api/v1/mentorships/create_mentor?private_token=\(validToken)")
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

extension BrowseTutorVC: SendEmailDelegate {
    func sendEmailTapped(_ employee: Employee, skill: Skill) {
        sendEmail(employee, skill: skill)
    }
}
