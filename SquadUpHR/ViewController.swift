//
//  ViewController.swift
//  SquadUpHR
//
//  Created by Max Jala on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
//import Starscream

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView?.dataSource = self
            collectionView?.delegate = self
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
    
        
    var skillCategory = SkillCategory.fetchAllCategories()
    let cellScaling: CGFloat = 0.6
    //let socket = WebSocket(url: URL(string: "ws://localhost:8080/")!)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let screenSize = UIScreen.main.bounds.size
            let cellWidth = floor(screenSize.width * cellScaling)
            let cellHeight = floor(screenSize.height * cellScaling)
            
            let insetX = (view.bounds.width - cellWidth) / 2.0
            let insetY = (view.bounds.height - cellHeight) / 2.0
            
            let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            collectionView?.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
            
            self.navigationController?.navigationBar.isHidden = true
            
            
        }
    }
    
    extension ViewController : UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return skillCategory.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! SkillCategoryViewCell
            
            cell.skillCategory = skillCategory[indexPath.item]
            
            return cell
        }
    }
    
    extension ViewController : UIScrollViewDelegate, UICollectionViewDelegate {
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
            let specificCategory = skillCategory[indexPath.item]
            
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SpecificCategoryVC") as? SpecificCategoryVC else {return}
            
            vc.category = specificCategory
            vc.displayType = .companySkills
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
        
}

