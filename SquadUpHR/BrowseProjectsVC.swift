//
//  BrowseProjectsVC.swift
//  SquadUpHR
//
//  Created by Max Jala on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class BrowseProjectsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.white
            tableView.tableFooterView = UIView()
            tableView.layer.cornerRadius = 10
            tableView.layer.masksToBounds = true
            
            tableView.register(ProjectViewCell.cellNib, forCellReuseIdentifier: ProjectViewCell.cellIdentifier)
        }
    }
    @IBOutlet weak var accentView: UIView! {
        didSet {
            accentView.layer.shadowRadius = 5
            accentView.layer.shadowOpacity = 0.2
            accentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        }
    }
    
    var selectedIndex : IndexPath?
    var isExpanded = false

    var projects : [Project] = []
    var currentUser : Employee?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureProjectsView()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarHidden()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    
    func configureProjectsView() {
        JSONConverter.fetchCurrentUser { (user, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            //let jsonResponse = currentUser
            if let validUser = user {
                self.generateUserProjects(validUser)
                self.createUserDetails(validUser)
                

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
        }
    }
    
    func generateUserProjects(_ userJSON: [Any]) {
        projects.removeAll()

        for each in userJSON {
            
            if let objects = each as? [[String: Any]] {
                
                for object in objects {
                    
                    if let desc = object["description"] as? String,
                        let title = object["title"] as? String,
                        let id = object["id"] as? Int,
                        let status = object["status"] as? String,
                        let skills = object["skills_array"] as? [[String:Any]] {
                        
                        var skillsArray : [String] = []
                        
                        for skill in skills {
                            guard let skillName = skill["skill_name"] as? String else {return}
                            skillsArray.append(skillName)
                            
                        }
                        
                        let newProj = Project(anID: id, aSkillsArray: skillsArray, aStatus: status, aTitle: title, aDesc: desc)
                        
                        projects.append(newProj)
                    }
                    
                }
            }
        
            
            
            
        }
    }
    
    func createUserDetails(_ userJSON: [Any]) {
        for each in userJSON {
            if let userInfo = each as? [String: Any] {
                guard let id = userInfo["id"] as? Int else {return}
                guard let jobTitle = userInfo["job_title"] as? String else {return}
                guard let department = userInfo["department"] as? String else {return}
                guard let firstName = userInfo["first_name"] as? String else {return}
                guard let lastName = userInfo["last_name"] as? String else {return}
                guard let email = userInfo["email"] as? String else {return}
                guard let privateToken = userInfo["private_token"] as? String else {return}
                guard let pictureURL = userInfo["profile_picture"] as? String else {return}

                currentUser = Employee(anID: id, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken, aPictureURL: pictureURL)
                
            }
        }
    }


}

extension BrowseProjectsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.cellIdentifier) as? ProjectViewCell else {return UITableViewCell()}
        
        let project = projects[indexPath.row]
        
        cell.projectNameLabel.text = project.projectTitle
        cell.descriptionLabel.text = project.projectDesc
        cell.delegate = self
        cell.project = project
    
        
        
        return cell
    }
    
    func segueToProjectVC(_ project: Project) {
        let projVC = storyboard?.instantiateViewController(withIdentifier: "ProjectViewController") as? ProjectViewController
        projVC?.project = project 
        projVC?.currentUser = currentUser
        navigationController?.pushViewController(projVC!, animated: true)
    }
    
    func segueToProjectChatVC(_ project: Project) {
        JSONConverter.getJSONResponse("projects/\(project.projectId)") { (projectMembers, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            
            let teamMates = JSONConverter.createProjectMembers(projectMembers!)
            
            DispatchQueue.main.async {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return}
                
                vc.project = project
                vc.projectMembers = teamMates
                vc.currentUser = self.currentUser
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }

        
    }
    

}

extension BrowseProjectsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded && self.selectedIndex == indexPath {
            return 102
        }
        return 30
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        didExpandCell()
    }
    
    func didExpandCell() {
        isExpanded = !isExpanded
        tableView.reloadRows(at: [selectedIndex!], with: .fade)
        tableView.scrollToRow(at: selectedIndex!, at: .bottom, animated: true)
    }
    
}

extension BrowseProjectsVC: ProjectRoleViewCellDelegate {
    func openProject(_ project: Project) {
        segueToProjectVC(project)
    }
    func openProjectChat(_ project: Project) {
        segueToProjectChatVC(project)
    }
}
