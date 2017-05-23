//
//  NotifiactionViewController.swift
//  SquadUpHR
//
//  Created by Max Jala on 22/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import ActionCableClient

class NotifiactionViewController: UIViewController {
    
    @IBOutlet weak var projectChatsButton: UIButton!
    
    @IBOutlet weak var projectInvitesButton: UIButton!
    
    @IBOutlet weak var mentorInvitesButton: UIButton!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            //tableView.register(ChatPreviewViewCell.cellNib, forCellReuseIdentifier: ChatPreviewViewCell.cellIdentifier)
            tableView.register(InviteTableViewCell.cellNib, forCellReuseIdentifier: InviteTableViewCell.cellIdentifier)
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
        }
    }

    var client = ActionCableClient(url: URL(string: "ws://192.168.1.114:3000/cable")!)
    
    var employees : [Employee] = []
    var projects : [Project] = []
    var currentUser : Employee?
    var chats : [Chat] = []
    
    var mentorList : [Mentorship] = []
    var menteeList : [Mentorship] = []
    var activeArray : [Mentorship] = []
    
    var isMentor = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllCompanyUsers()
        fetchCurrentUser()
        fetchMentorships()
        
        DispatchQueue.main.async {
            self.activeArray = self.mentorList
            self.tableView.reloadData()
        }
        
        //print(chats.count)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getAllCompanyUsers() {
        JSONConverter.getJSONResponse("users") { (workers, error) in
            if let validError = error {
                print(validError.localizedDescription)
                return
            }
            
            if let validWorkers = workers {
                self.employees = JSONConverter.createObjects(validWorkers) as! [Employee]
            }

        }
        
    }

    func fetchCurrentUser() {
        JSONConverter.fetchCurrentUser { (user, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            //let jsonResponse = currentUser
            if let validUser = user {
                self.createUserDetails(validUser)

 
            }
            
            
        }
    }
    
    func createUserDetails(_ userJSON: [Any]) {
        self.projects.removeAll()
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
                    if let desc = object["description"] as? String,
                        let title = object["title"] as? String,
                        let id = object["id"] as? Int,
                        let status = object["status"] as? String {
                        
                        let newProj = Project(anID: id, aUserID: 0, aStatus: status, aTitle: title, aDesc: desc)
                        
                        projects.append(newProj)
                    } 
                }
            }
            
        }
    }
    
    func fetchMentorships() {
        JSONConverter.getJSONResponse("mentorships/mentees") { (mentees, error) in
            if let err = error {
                print(error?.localizedDescription)
            }
            
            if let validMentees = mentees {
                DispatchQueue.main.async {
                    self.menteeList = self.createMentorMenteeList(validMentees, type: "mentee_id")
                }
            }
        }
        
        JSONConverter.getJSONResponse("mentorships/mentors") { (mentors, error) in
            if let err = error {
                print(error?.localizedDescription)
            }
            
            if let validMentors = mentors {
                DispatchQueue.main.async {
                    self.mentorList = self.createMentorMenteeList(validMentors, type: "mentor_id")
                }
            }
        }
    }
    
    func createMentorMenteeList(_ mentors: [[String:Any]], type: String) -> [Mentorship] {
        var menteeMentorList : [Mentorship] = []
        var constructedMessage = ""
        
        for each in mentors {
            if let firstName = each["first_name"] as? String,
                let lastName = each["last_name"] as? String,
                let mentorID = each[type] as? Int,
                let status = each["request_approval"] as? String {
                
                if type == "mentor_id" {
                    if status == "pending" {
                        constructedMessage = "awaiting response for" + "subject" + "help"
                    } else if status == "accepted" {
                        constructedMessage = "is now your \("subject") mentor"
                    } else {
                        constructedMessage = "is too busy to help right now..."
                    }
                }
                
                if type == "mentee_id" {
                    if status == "pending" {
                        constructedMessage = "is requesting \("subject") help."
                    } else if status == "accepted" {
                        constructedMessage = "is now your \("subject") mentee"
                    } else {
                        constructedMessage = "you are too busy to help right now..."
                    }
                }
                
                let mentorship = Mentorship(aUserID: mentorID, aMenteeFirst: firstName, aMenteeLast: lastName, aStatus: status, aSubject: "", aMessage: constructedMessage)
                
                menteeMentorList.append(mentorship)
                
            }
        }
        
        return menteeMentorList
    }



    func mentorInvitesSegmentTapped() {
        activeArray = mentorList
        isMentor = true
        tableView.reloadData()
    }
    
    func menteeInvitesSegmentTapped() {
        isMentor = false
        activeArray = menteeList
        tableView.reloadData()
    }
    
    func projectChatsSegmentTapped() {
        //activeArray = projects
        //collectionView.reloadData()
    }
    
}

extension NotifiactionViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mentorMentee = activeArray[indexPath.row]
        
        if isMentor == true {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell") as? InviteTableViewCell else {return UITableViewCell()}
            
            cell.nameLabel.text = mentorMentee.menteeFullName
            cell.requestLabel.text = mentorMentee.message
            
            return cell
   
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell") as? InviteTableViewCell else {return UITableViewCell()}
        
        
        return cell
        
    }
}

extension NotifiactionViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BrowseTutorVC") as? BrowseTutorVC else {return}
        
        //vc.skill = skills[indexPath.row]
        //vc.viewType = .specificSkill
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotifiactionViewController {
    func setUpActionCableConnection(_ projectID : Int) {
        client.connect()
        
        let room_identifier = ["project_id" : projectID]
        let roomChannel = client.create("ApiProjectChatsChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)
        
        client.onConnected = {
            print("Connected!")
        }
        
        client.onDisconnected = {(error: Error?) in
            print("Disconnected!")
        }
        
    
        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON, error)
            //self.fetchChat()
            guard let formattedJSON = JSON as? [String:Any],
                let messageJSON = formattedJSON["chat_message_object"] as? [String:Any],
                let message = messageJSON["message"] as? String,
                let senderID = messageJSON["user_id"] as? Int
                else {return}
            
            var messages : [[String:Any]] = []
            
            for person in self.employees {
                if person.employeeID == senderID {
                    messages.append(["senderName": person.firstName, "message": message])
                    //messages.append(JSQMessage(senderId: "\(senderID)", displayName: person.firstName, text: message))
                }
            }
            //let lastIndex = IndexPath(item: self.messages.count - 1, section: 0)
            //self.tableview.reloadData()
            //self.tableview.scrollToItem(at: lastIndex, at: .bottom, animated: true)
        }
        
        // A channel has successfully been subscribed to.
        roomChannel.onSubscribed = {
            print("Yay!")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel.onRejected = {
            print("Rejected")
        }
    }
    
}
