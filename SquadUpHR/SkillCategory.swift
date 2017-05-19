//
//  SkillCategory.swift
//  SquadUpHR
//
//  Created by Max Jala on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation
import UIKit

class SkillCategory {
    // MARK: - Public API
    var title = ""
    var featuredImage: UIImage
    var color: UIColor
    var skills: [Skill] = []
    
    init(title: String, featuredImage: UIImage, color: UIColor)
    {
        self.title = title
        self.featuredImage = featuredImage
        self.color = color
    }
    
    static func fetchAllCategories() -> [SkillCategory] {
        return [
            SkillCategory(title: "Management", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 240/255.0, green: 133/255.0, blue: 91/255.0, alpha: 0.8)),
            SkillCategory(title: "Accountancy", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 105/255.0, green: 80/255.0, blue: 227/255.0, alpha: 0.8)),
            SkillCategory(title: "Design", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 245/255.0, green: 62/255.0, blue: 40/255.0, alpha: 0.8)),
            SkillCategory(title: "IT", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 103/255.0, green: 217/255.0, blue: 87/255.0, alpha: 0.8)),
            
            SkillCategory(title: "Education", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 150/255.0, green: 102/255.0, blue: 102/255.0, alpha: 0.8)),
            SkillCategory(title: "Others", featuredImage: UIImage(named: "desgin")!, color: UIColor(red: 63/255.0, green: 51/255.0, blue: 80/255.0, alpha: 0.8))
            
            
        ]
    }
    
    static func assignSkills(_ skills: [Skill], skillCategories: [SkillCategory]) -> [SkillCategory] {
        var returnedSkillCats : [SkillCategory] = []
        
        for skillcat in skillCategories {
            for skill in skills {
                if skill.skillCategory == skillcat.title {
                    skillcat.skills.append(skill)
                }
            }
            
            if skillcat.skills.count > 0 {
                returnedSkillCats.append(skillcat)
            }
        }
        
        return returnedSkillCats
        
    }
    
    
}
