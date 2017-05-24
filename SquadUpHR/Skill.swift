//
//  Skill.swift
//  SquadUpHR
//
//  Created by Max Jala on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class Skill {
    var id: Int = 0
    var skillName: String = ""
    var skillCategory: String = ""
    
    init(anID: Int, aSkill: String, aSkillCategory: String){
        id = anID
        skillName = aSkill
        skillCategory = aSkillCategory
    }
    
}
