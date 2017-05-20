//
//  BrowseTutorVC.swift
//  SquadUpHR
//
//  Created by Max Jala on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseDatabase

enum ViewType {
    case specificSkill
    case allUsers
    
}


class BrowseTutorVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var connectLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(EmployeeTableViewCell.cellNib, forCellReuseIdentifier: EmployeeTableViewCell.cellIdentifier)
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
    
    var ref: FIRDatabaseReference!
    
    
    var employees : [Employee] = []
    var skill: Skill?
    var viewType: ViewType = .allUsers
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        
        // Do any additional setup after loading the view.
        
        //mockEmployees()
        //getAllCompanyUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewType(viewType)
    }
    
    func getAllCompanyUsers() {
        //guard let JSONResponse = JSONConverter.fetchJSONResponse("users") else {return}
        //employees = JSONConverter.createObjects(JSONResponse) as! [Employee]
        //employees = JSONConverter.createObjects(JSONConverter.fetchJSONResponse("users")!) as! [Employee]
        
        JSONConverter.getJSONResponse("users") { (workers, error) in
            if let validError = error {
                print(validError.localizedDescription)
                return
            }
            
            self.employees = JSONConverter.createObjects(workers!) as! [Employee]
            self.tableView.reloadData()
        }
        
    }
    
    func mockEmployees() {
        //let emp1 = Employee(anID: "123", aJobTitle: "iOS Developer", aDepartment: "IT", aFirstName: "Max", aLastName: "Jala", anEmail: "maxjala@gmail.com")
        //let emp2 = Employee(anID: "123", aJobTitle: "iOS Developer", aDepartment: "IT", aFirstName: "Max", aLastName: "Jala", anEmail: "maxjala@gmail.com")
        //let emp3 = Employee(anID: "123", aJobTitle: "iOS Developer", aDepartment: "IT", aFirstName: "Max", aLastName: "Jala", anEmail: "maxjala@gmail.com")
        
        let emp1 = ["private_token": "12313", "firstName": "Max", "lastName": "Jala", "jobTitle": "iOS Developer", "department": "IT", "email": "maxjala@gmail.com"]
        let emp2 = ["private_token": "12313", "firstName": "Max", "lastName": "Jala", "jobTitle": "iOS Developer", "department": "IT", "email": "maxjala@gmail.com"]
        let emp3 = ["private_token": "12313", "firstName": "Max", "lastName": "Jala", "jobTitle": "iOS Developer", "department": "IT", "email": "maxjala@gmail.com"]
        
        let mockArray : [[String:Any]] = [emp1,emp2,emp3]
        
        employees = JSONConverter.createObjects(mockArray) as! [Employee]
        
    }
    
    @IBAction func emailButtonTapped(_ sender: Any) {
        sendEmail()
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients(["maxjala@gmail.com"])
            mail.setMessageBody("<p>Hey Friend! I am requesting mentorship through SquadUp!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        controller.dismiss(animated: true, completion: nil)    }
    
    func configureViewType(_ view: ViewType){
        switch view {
        case .allUsers:
            getAllCompanyUsers()
        case .specificSkill:
            //createFilteredEmployeeList()
            something()
            break
        }
    }
    
    func something(){
        JSONConverter.fetchAllUsers { (users, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            //let jsonResponse = currentUser
            if let validUsers = users {
                self.createFilteredEmployeeList(validUsers)
                //self.userCategories = SkillCategory.assignSkills(self.skillArray, skillCategories: self.genericCategoies)
                //self.activeArray = self.userCategories
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    //self.nameLabel.text = self.currentUser?.fullName
                    
                }
            }
            
            
        }
    }
    
    func createFilteredEmployeeList(_ userJSON: [Any]) {
        var aUser : Employee?
        employees.removeAll()
        
        for each in userJSON {
            if let userInfo = each as? [String: Any] {
                guard let id = userInfo["id"] as? Int else {return}
                guard let jobTitle = userInfo["job_title"] as? String else {return}
                guard let department = userInfo["department"] as? String else {return}
                guard let firstName = userInfo["first_name"] as? String else {return}
                guard let lastName = userInfo["last_name"] as? String else {return}
                guard let email = userInfo["email"] as? String else {return}
                guard let privateToken = userInfo["private_token"] as? String else {return}
                guard let skillsArray = userInfo["skills_array"] as? [[String:Any]] else {return}
                
                for aSkill in skillsArray {
                    if aSkill["skill_name"] as? String == skill?.skillName {
                        aUser = Employee(anID: id, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken)
                        
                        employees.append(aUser!)
                    }
                }
                
                
                
            }
            
            
            
        }
    }
}
extension BrowseTutorVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeTableViewCell.cellIdentifier) as? EmployeeTableViewCell else {return UITableViewCell()}
        
        let employee = employees[indexPath.row]
        
        cell.nameLabel.text = employee.fullName
        cell.jobTitleLabel.text = employee.jobTitle
        
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

