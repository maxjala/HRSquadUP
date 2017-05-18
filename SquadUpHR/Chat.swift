//
//  Chat.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class Chat {
    var id: Int = 0
    var userName : String = ""
    var body : String = ""
    var imageURL : String = ""
    var timestamp : String = ""
    
    init(anId: Int, aUserName: String, aBody: String, anImageURL: String, aTimestamp: String) {
        id = anId
        userName = aUserName
        body = aBody
        imageURL = anImageURL
        timestamp = aTimestamp
    }
}
