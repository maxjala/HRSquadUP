//
//  ProjectViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProjectViewController: UIViewController {
    
    var project : Project?
    var teamMates : [Employee] = []
    var currentUser : Employee?

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    

    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var ref: FIRDatabaseReference!
   
   
    var colorArray : [UIColor] = []
    
    var teamSelection : [[String:String]] = []
    let cellScaling: CGFloat = 0.6
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureProjectProfile()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customDesign()
        customColor()
        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()

        
        configureProjectProfile()
    }
    
    func configureProjectProfile() {
        guard let proj = project else {return}
        
        JSONConverter.getJSONResponse("projects/\(proj.projectId)") { (projectMembers, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            
            self.teamMates = JSONConverter.createObjects(projectMembers!) as! [Employee]
            
            DispatchQueue.main.async {
                self.projectNameLabel.text = proj.projectTitle
                self.projectNameLabel.text = proj.projectDesc
                self.collectionView.reloadData()
            }
        }
    }


    func customDesign(){
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * 0.4)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    func customColor(){
        let color1 = UIColor(red: 44.0/255.0, green: 150.0/255.0, blue: 163.0/255.0, alpha: 1)
        let color2 = UIColor(red: 179.0/255.0, green: 225.0/255.0, blue: 232.0/255.0, alpha: 1)
        let color3 = UIColor(red: 241.0/255.0, green: 90.0/255.0, blue: 41.0/255.0, alpha: 1)
        let color4 = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 35.0/255.0, alpha: 1)
        let color5 = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1)
        let color6 = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 59.0/255.0, alpha: 1)
        let color7 = UIColor(red: 45.0/255.0, green: 128.0/255.0, blue: 188.0/255.0, alpha: 1)
        let color8 = UIColor(red: 238.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
        let color9 = UIColor(red: 53.0/255.0, green: 151.0/255.0, blue: 211.0/255.0, alpha: 1)
        
        
        colorArray = [color1,color2,color3,color4,color5,color6,color7,color8,color9]
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return}
        
        vc.project = project
        vc.projectMembers = teamMates
        vc.currentUser = currentUser
        
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}

extension ProjectViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamMates.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath) as! TeamCollectionViewCell
        
        let employee = teamMates[indexPath.row]
        
        //cell.backgroundColor = colorArray[Int(arc4random_uniform(UInt32(colorArray.count)))]
        cell.backgroundColor = colorArray[indexPath.row]
        cell.nameLabel.text = employee.fullName
        //cell.roleLabel.text =
        
        return cell
        
    }
}

extension ProjectViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let specificEmployee = teamMates[indexPath.item]
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
        vc.profileType = .otherProfile
        vc.selectedProfile = specificEmployee
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
