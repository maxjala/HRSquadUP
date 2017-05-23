//
//  Employee.swift
//  SquadUpHR
//
//  Created by nicholaslee on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class Employee{
    var firstName: String = ""
    var lastName: String = ""
    var jobTitle: String = ""
    var department: String = ""
    var companyID: Int = 0
    var accessLevel: Int = 0
    var email: String = ""
    var employeeID : Int = 0
    var fullName: String = ""
    var privateToken : String = ""
    var pictureURL : String = ""
    
    
    init(anID: Int, aJobTitle: String, aDepartment: String, aFirstName: String, aLastName: String, anEmail: String, aPrivateToken: String, aPictureURL: String) {
    
        employeeID = anID
        jobTitle = aJobTitle
        department = aDepartment
        firstName = aFirstName
        lastName = aLastName
        email = anEmail
        privateToken = aPrivateToken
        pictureURL = aPictureURL
        
        fullName = firstName + " " + lastName
        
    }
    
    
    
}
