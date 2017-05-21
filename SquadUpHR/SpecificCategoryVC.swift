//
//  SpecificCategoryVC.swift
//  SquadUpHR
//
//  Created by Max Jala on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

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
    var skills: [String] = []
    
    var newSkills: [Skill] = []
    
    var displayType : DisplayType = .companySkills
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchSkills()
        categoryLabel.text = category?.title
        accentView.backgroundColor = category?.color
        
        configureDisplayType(displayType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func configureDisplayType (_ type : DisplayType) {
        switch type {
        case .companySkills :
            
            configureCompany()
        case .userSkills:
            
            configureUser()
            break
            
        }
    }
    
    func configureUser() {
        guard let skils = category?.skills else {return}
        newSkills = []
        newSkills = skils
        
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
        newSkills = []
        for each in json {
            if let skill = each["skill_name"] as? String,
                let cat = each["category"] as? String {
                if cat == category?.title {
                    let newSkill = Skill(aSkill: skill, aSkillCategory: cat)
                    newSkills.append(newSkill)
                }
            }
            
        }
    }
    
}

extension SpecificCategoryVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSkills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell") as? SkillTableViewCell else {return UITableViewCell()}
        //cell.skillLabel.text = skills[indexPath.row]
        //cell.skillLabel.textColor = category?.color
        //cell.skillLabel.alpha = 0.8
        
        cell.skillLabel.text = newSkills[indexPath.row].skillName
        
        return cell
        
    }
}

extension SpecificCategoryVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BrowseTutorVC") as? BrowseTutorVC else {return}
        
        vc.skill = newSkills[indexPath.row]
        vc.viewType = .specificSkill
        
       navigationController?.pushViewController(vc, animated: true)
    }
}




