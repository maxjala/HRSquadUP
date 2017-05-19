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
            //tableView.allowsSelection = false
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.white
            //tableView.spacin
            tableView.tableFooterView = UIView()
            tableView.layer.cornerRadius = 10
            tableView.layer.masksToBounds = true
            
            tableView.register(ProjectViewCell.cellNib, forCellReuseIdentifier: ProjectViewCell.cellIdentifier)
            
            //tableView.estimatedRowHeight = 253
            //tableView.rowHeight = UITableViewAutomaticDimension
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mockProjects()
    }

    func mockProjects() {
        let proj1 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "iOS Project", aDesc: "Create HR App")
        let proj2 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Web Project", aDesc: "Dont Create HR App")
        let proj3 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Who Cares Project", aDesc: "Hello HR App")
        let proj4 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Data Project", aDesc: "Create HR App")
        let proj5 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Cmon Project", aDesc: "Create HR App")
        let proj6 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "iOS Project", aDesc: "Create HR App")
        let proj7 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Web Project", aDesc: "Dont Create HR App")
        let proj8 = Project(anID: 123, aUserID: 123, aStatus: "", aTitle: "Who Cares Project", aDesc: "Hello HR App")
        
        projects = [proj1, proj2, proj3, proj4, proj5, proj6, proj7, proj8]
        
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
        
            cell.projectNameLabel.text = project.projectTitle
            cell.descriptionLabel.text = project.projectDesc
        
        
        return cell
    }
    

}

extension BrowseProjectsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded && self.selectedIndex == indexPath {
            return 182
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
