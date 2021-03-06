//
//  FetchJSON.swift
//  SquadUpHR
//
//  Created by Max Jala on 17/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

class JSONConverter {

    //Applicable for "_ url: String" :  "projects", "users/skills", "projects/1" (1 is project id... this call shows project members only)
    static func getJSONResponse(_ url: String, completion: @escaping (_ completed:[[String:Any]]?, Error?)->Swift.Void) {
        //call the json to fetch all Projects
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        let completedURL = URL(string: "http://192.168.1.33:3000/api/v1/\(url)?private_token=\(validToken)")
        //let completedURL = URL(string: "http://192.168.1.155:3000/api/v1/\(url)?private_token=\(validToken)")
        //var createdArray : [Any] = []
        
        var urlRequest = URLRequest(url: completedURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data,response,error) in
            
            if let validError = error {
                print(validError.localizedDescription)
                completion(nil, validError)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [[String : Any]] else {return}
                        
                        completion(validJSON, nil)
    
    
                    }catch let jsonError as NSError {
                        completion(nil, jsonError)
                    }
                }
            }
            
        }
        dataTask.resume()
    }
    
    static func fetchCurrentUser(completion: @escaping (_ completed:[Any]?, Error?)->Swift.Void) {
        //call the json to fetch all Projects
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        let completedURL = URL(string: "http://192.168.1.33:3000/api/v1/current_user?private_token=\(validToken)")
        //let completedURL = URL(string: "http://192.168.1.155:3000/api/v1/current_user?private_token=\(validToken)")
        
        //var createdArray : [Any] = []
        
        var urlRequest = URLRequest(url: completedURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data,response,error) in
            
            if let validError = error {
                print(validError.localizedDescription)
                completion(nil, validError)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [Any] else {return}
                        
                        completion(validJSON, nil)
                        
                        
                    }catch let jsonError as NSError {
                        completion(nil, jsonError)
                    }
                }
            }
            
        }
        dataTask.resume()
    }
    
    static func fetchAllUsers(completion: @escaping (_ completed:[Any]?, Error?)->Swift.Void) {
        //call the json to fetch all Projects
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        //let completedURL = URL(string: "http://192.168.1.114:3000/api/v1/users?private_token=\(validToken)")
        let completedURL = URL(string: "http://192.168.1.33:3000/api/v1/users?private_token=\(validToken)")
        
        //var createdArray : [Any] = []
        
        var urlRequest = URLRequest(url: completedURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data,response,error) in
            
            if let validError = error {
                print(validError.localizedDescription)
                completion(nil, validError)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [Any] else {return}
                        
                        completion(validJSON, nil)
                        
                        
                    }catch let jsonError as NSError {
                        completion(nil, jsonError)
                    }
                }
            }
            
        }
        dataTask.resume()
    }
    
    static func fetchSelectedUser(_ selectedID: Int, completion: @escaping (_ completed:[Any]?, Error?)->Swift.Void) {
        //call the json to fetch all Projects
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        let completedURL = URL(string: "http://192.168.1.33:3000/api/v1/user/\(selectedID)?private_token=\(validToken)")
        //let completedURL = URL(string: "http://192.168.1.53:3000/api/v1/user/\(selectedID)?private_token=\(validToken)")
        //var createdArray : [Any] = []
        
        var urlRequest = URLRequest(url: completedURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data,response,error) in
            
            if let validError = error {
                print(validError.localizedDescription)
                completion(nil, validError)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [Any] else {return}
                        
                        completion(validJSON, nil)
                        
                        
                    }catch let jsonError as NSError {
                        completion(nil, jsonError)
                    }
                }
            }
            
        }
        dataTask.resume()
    }
    
    static func createObjects(_ jsonResponse: [[String : Any]]) -> [Any] {
        
        var returnedArray : [Any] = []
        
        for each in jsonResponse {
            
            //Create Projects
            if let projectID = each["projectId"] as? Int,
                let userID = each["userId"] as? Int,
                let status = each["status"] as? String,
                let projectTitle = each ["projectTitle"] as? String,
                let projectDesc = each["projectDesc"] as? String,
                let skills = each["skills_array"] as? [[String:Any]] {
                
                var skillsArray : [String] = []
                
                for skill in skills {
                    if let skillName = skill["skill_name"] as? String {
                        skillsArray.append(skillName)
                    }
                    
                }
                
                let project = Project(anID: projectID, aSkillsArray: skillsArray, aStatus: status, aTitle: projectTitle, aDesc: projectDesc)
                
                //projects.append(project)
                returnedArray.append(project)
                //return projects
            }
            
            //Create Employees
            if let employeeID = each["id"] as? Int,
                let firstName = each["first_name"] as? String,
                let lastName = each["last_name"] as? String,
                let jobTitle = each ["job_title"] as? String,
                let email = each["email"] as? String,
                let privateToken = each ["private_token"] as? String,
                let department = each["department"] as? String,
                let pictureURL = each["profile_picture"] as? String {
                
                let employee = Employee(anID: employeeID, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken, aPictureURL: pictureURL)
                //projects.append(project)
                returnedArray.append(employee)
                //return projects
            }
            
            
        }
        
        return returnedArray
        
    }
    
    static func createProjectMembers(_ jsonResponse: [[String : Any]]) -> [Employee] {
        
        var returnedArray : [Employee] = []
        
        for each in jsonResponse {
            

            //Create Employees
            if let employeeID = each["id"] as? Int,
                let firstName = each["first_name"] as? String,
                let lastName = each["last_name"] as? String,
                let jobTitle = each ["job_title"] as? String,
                let email = each["email"] as? String,
                let privateToken = each ["private_token"] as? String,
                let department = each["department"] as? String,
                let pictureURL = each["profile_picture"] as? [String:Any],
                let url = pictureURL["url"] as? String {
                
                let employee = Employee(anID: employeeID, aJobTitle: jobTitle, aDepartment: department, aFirstName: firstName, aLastName: lastName, anEmail: email, aPrivateToken: privateToken, aPictureURL: url)
                //projects.append(project)
                returnedArray.append(employee)
                //return projects
            }
            
            
        }
        
        return returnedArray
        
    }
    
    static func fetchChatHistory(_ projectID: Int, completion: @escaping (_ completed:[[String:Any]]?, Error?)->Swift.Void) {
        //call the json to fetch all Projects
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        
        //let completedURL = URL(string: "http://192.168.1.114:3000/api/v1/\(url)?private_token=\(validToken)")
        //let completedURL = URL(string: "http://192.168.1.155:3000/api/v1/\(url)?private_token=\(validToken)")
        //var createdArray : [Any] = []
        let completedURL = URL(string: "http://192.168.1.33:3000/api/v1/project_chats?private_token=\(validToken)&project_id=\(projectID)")
        
        var urlRequest = URLRequest(url: completedURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data,response,error) in
            
            if let validError = error {
                print(validError.localizedDescription)
                completion(nil, validError)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [[String : Any]] else {return}
                        
                        completion(validJSON, nil)
                        
                        
                    }catch let jsonError as NSError {
                        completion(nil, jsonError)
                    }
                }
            }
            
        }
        dataTask.resume()
    }
    
    

}
