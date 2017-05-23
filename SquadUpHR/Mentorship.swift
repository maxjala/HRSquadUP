//
//  Mentorship.swift
//  SquadUpHR
//
//  Created by Max Jala on 22/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class Mentorship {
    var userID: Int = 0
    var mentorLastName: String = ""
    var mentorFullName: String = ""
    var menteeFirstName: String = ""
    var menteeLastName: String = ""
    var menteeFullName: String = ""
    var status: String = ""
    var subject: String = ""
    var message: String = ""
    
    init(aUserID: Int, aMenteeFirst: String, aMenteeLast: String, aStatus: String, aSubject: String, aMessage: String) {
        menteeFirstName = aMenteeFirst
        menteeLastName = aMenteeLast
        menteeFullName = aMenteeFirst + aMenteeLast
        
        userID = aUserID

        subject = aSubject
        status = aStatus
        message = aMessage
        
    }
    
}
