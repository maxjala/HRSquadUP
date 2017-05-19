//
//  ProfileViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var skillsButton: UIButton!{
        didSet{
            skillsButton.addTarget(self, action: #selector(skillButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var projectsButton: UIButton!{
        didSet{
            projectsButton.addTarget(self, action: #selector(projectButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var addSkillButton: UIButton!{
        didSet{
            //addSkillButton.addTarget(self, action: #selector(addSkills), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.dataSource = self
            collectionView.delegate = self
            
            collectionView.register(SkillCollectionViewCell.cellNib, forCellWithReuseIdentifier: SkillCollectionViewCell.cellIdentifier)
            collectionView.register(ProjectRoleViewCell.cellNib, forCellWithReuseIdentifier: ProjectRoleViewCell.cellIdentifier)
            
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
    
    
    var projects : [Project] = []
    var genericCategoies = SkillCategory.fetchAllCategories()
    var userCategories : [SkillCategory] = []
    var activeArray : [Any] = []
    
    var currentUser : Employee?
    var skillArray : [Skill] = []
    
    let cellScaling: CGFloat = 0.6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionViewProperties()
        
        //mockProjects()
        collectionView.reloadData()
        
        
       self.navigationController?.navigationBar.isHidden = true
        
        //getCurrentUserDetails()
        //navigationController?.isUserInteractionEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getCurrentUserDetails()
        
        //activeArray = userCategories
        
        mockSkills()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func getCurrentUserDetails() {
        JSONConverter.fetchCurrentUser { (user, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            //let jsonResponse = currentUser
            if let validUser = user {
                self.createCurrentUserDetails(validUser)
                self.userCategories = SkillCategory.assignSkills(self.skillArray, skillCategories: self.genericCategoies)
                
                self.nameLabel.text = self.currentUser?.fullName
                self.jobTitleLabel.text = self.currentUser?.jobTitle
            }
            
            
        }
    }
    
    func mockSkills() {
        skillArray.removeAll()
        
        skillArray.append(Skill.init(aSkill: "hello", aSkillCategory: "Management"))
        skillArray.append(Skill.init(aSkill: "cmon", aSkillCategory: "Design"))
        skillArray.append(Skill.init(aSkill: "why", aSkillCategory: "Accountancy"))
        
        
        userCategories = SkillCategory.assignSkills(skillArray, skillCategories: genericCategoies)
        activeArray = userCategories
    }
    
    
    func createCurrentUserDetails(_ userJSON: [Any]) {
        for each in userJSON {
            if let userInfo = each as? [String: Any] {
                guard let id = userInfo["id"] as? Int else {return}
                guard let jobTitle = userInfo["job_title"] as? String else {return}
                guard let department = userInfo["department"] as? String else {return}
                guard let firstName = userInfo["first_name"] as? String else {return}
                guard let lastName = userInfo["last_name"] as? String else {return}
                guard let email = userInfo["email"] as? String else {return}
                guard let privateToken = userInfo["private_token"] as? String else {return}
                
                //Need to account for Profile Picture when STORAGE is ready
                
                currentUser = Employee(anID: id, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken)
                
            }
            
            if let objects = each as? [[String: Any]] {
                
                for object in objects {
                    if let aSkill = object["skill_name"] as? String,
                        let aCategory = object["category"] as? String {
                        
                        let newSkill = Skill(aSkill: aSkill, aSkillCategory: aCategory)
                        skillArray.append(newSkill)
                        
                    }
                    
                    if let desc = object["description"] as? String,
                        let title = object["title"] as? String,
                        let id = object["id"] as? Int {
                        
                        let newProj = Project(anID: id, aUserID: 0, aStatus: 0, aTitle: title, aDesc: desc)
                        
                        projects.append(newProj)
                    }
                    
                }
            }
            
            
            
            
        }
    }
    
        
    
    func setCollectionViewProperties() {
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * 0.4)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView?.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    func mockProjects() {
        let proj1 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj2 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj3 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj4 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        let proj5 = Project(anID: 123, aUserID: 123, aStatus: 2, aTitle: "iOS Project", aDesc: "Create HR App")
        
        projects = [proj1, proj2, proj3, proj4, proj5]
        
    }
    
    func skillButtonTapped() {
        activeArray = userCategories
        collectionView.reloadData()
    }
    
    func projectButtonTapped() {
        activeArray = projects
        collectionView.reloadData()
    }
    
    
}

extension ProfileViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let currentObject = activeArray[indexPath.row]
        
        if let skillObject = currentObject as? SkillCategory {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkillCollectionViewCell.cellIdentifier, for: indexPath) as? SkillCollectionViewCell else {return UICollectionViewCell()}
            
            cell.skillCategory = skillObject
            
            return cell
            
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectRoleViewCell.cellIdentifier, for: indexPath) as? ProjectRoleViewCell else {return UICollectionViewCell()}
        
        let currentProject = currentObject as! Project
        
        cell.projectNameLabel.text = currentProject.projectTitle
        //cell.descriptionLabel.text = currentProject.projectDesc
        //cell.statusLabel.text = currentProject.status
        
        //this will be a problem soon
        cell.backgroundColor = genericCategoies[indexPath.row].color
        cell.alpha = 0.6
        return cell
    }
}

extension ProfileViewController : UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let skillCat = activeArray as? [SkillCategory] {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SpecificCategoryVC") as? SpecificCategoryVC
            vc?.category = skillCat[indexPath.row]
            vc?.displayType = .userSkills
            
            navigationController?.pushViewController(vc!, animated: true)

        }
    }
    
    
    
    
    
}


