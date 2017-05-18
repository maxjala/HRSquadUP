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
            tableView.allowsSelection = false
            tableView.separatorStyle = .none
            
            tableView.register(ProjectViewCell.cellNib, forCellReuseIdentifier: ProjectViewCell.cellIdentifier)
        }
    }
    
    var t_count: Int = 0
    var lastCell : ProjectViewCell = ProjectViewCell()
    var button_tag : Int = -1

    
    
    var projects : [Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mockProjects()
    }

    func mockProjects() {
        let proj1 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj2 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Web Project", aDesc: "Dont Create HR App")
        let proj3 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Who Cares Project", aDesc: "Hello HR App")
        let proj4 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Data Project", aDesc: "Create HR App")
        let proj5 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Cmon Project", aDesc: "Create HR App")
        let proj6 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj7 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Web Project", aDesc: "Dont Create HR App")
        let proj8 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Who Cares Project", aDesc: "Hello HR App")
        let proj9 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Data Project", aDesc: "Create HR App")
        let proj10 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "Cmon Project", aDesc: "Create HR App")
        
        projects = [proj1, proj2, proj3, proj4, proj5, proj6, proj7, proj8, proj9, proj10]
        
        tableView.reloadData()
        
    }

}

extension BrowseProjectsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.cellIdentifier) as? ProjectViewCell else {return UITableViewCell()}
        
        let project = projects[indexPath.row]
        

        if !cell.cellExist {
            cell.titleButton.setTitle(project.projectTitle, for: .normal)
            cell.descriptionLabel.text = project.projectDesc
            cell.titleButton.tag = t_count
            cell.titleButton.addTarget(self, action: #selector(cellOpened(sender:)), for: .touchUpInside)
            t_count += 1
            cell.cellExist = true
        }
        
        
        
        UIView.animate(withDuration: 0) {
            cell.contentView.layoutIfNeeded()
        }
        
        
        return cell
    }
    
    func cellOpened(sender:UIButton) {
        self.tableView.beginUpdates()
        
        let previousCellTag = button_tag
        
        if lastCell.cellExist {
            self.lastCell.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
            
            if sender.tag == button_tag {
                button_tag = -1
                lastCell = ProjectViewCell()
            }
        }
        
        if sender.tag != previousCellTag {
            button_tag = sender.tag
            
            lastCell = tableView.cellForRow(at: IndexPath(row: button_tag, section: 0)) as! ProjectViewCell
            self.lastCell.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
            
        }
        self.tableView.endUpdates()
    }

}

extension BrowseProjectsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == button_tag {
            return 253
        } else {
            return 60
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
