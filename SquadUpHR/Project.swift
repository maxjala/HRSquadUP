//
//  Project.swift
//  SquadUpHR
//
//  Created by nicholaslee on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class Project {
    var projectId : Int = 0
    var userId: Int = 0
    var status: String = ""
    var projectTitle: String = ""
    var projectDesc: String = ""
    var skillsArray: [String] = []
    
    
    init(anID: Int, aSkillsArray: [String], aStatus: String, aTitle: String, aDesc: String) {
        projectId = anID
        skillsArray = aSkillsArray
        status = aStatus
        projectTitle = aTitle
        projectDesc = aDesc
    }
}
