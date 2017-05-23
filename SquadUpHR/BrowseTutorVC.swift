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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewType(viewType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    func configureViewType(_ view: ViewType){
        switch view {
        case .allUsers:
            getAllCompanyUsers()
        case .specificSkill:
            getEmployeesWithRelevantSkill()
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
                self.createFilteredEmployeeList(validUsers)
                self.filtered = self.employees
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func createFilteredEmployeeList(_ userJSON: [Any]) {
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
                guard let pictureURL = userInfo["profile_picture"] as? String else {return}
                
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
        
        cell.delegate = self
        cell.employee = employee
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
    func sendEmail(_ employee: Employee) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([employee.email])
            mail.setMessageBody("<p>Hey Friend! I am requesting mentorship through SquadUp!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        controller.dismiss(animated: true, completion: nil)
    
    }
    

}
extension BrowseTutorVC: SendEmailDelegate {
    func sendEmailTapped(_ employee: Employee) {
        sendEmail(employee)
    }
}
