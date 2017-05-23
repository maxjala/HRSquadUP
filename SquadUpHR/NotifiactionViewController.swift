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
    @IBOutlet weak var mentorInvitesButton: UIButton! {
        didSet{
            mentorInvitesButton.addTarget(self, action: #selector(mentorInvitesSegmentTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var menteeInvitesButton: UIButton! {
        didSet{
            menteeInvitesButton.addTarget(self, action: #selector(menteeInvitesSegmentTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(ResponseTableViewCell.cellNib, forCellReuseIdentifier: ResponseTableViewCell.cellIdentifier)
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
        
        //getAllCompanyUsers()
        //fetchCurrentUser()
        fetchMentorships()
        
        DispatchQueue.main.async {
            self.activeArray = self.mentorList
        }
        
        //print(chats.count)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func fetchMentorships() {
        JSONConverter.getJSONResponse("mentorships/mentee") { (mentees, error) in
            if let err = error {
                print(error?.localizedDescription)
            }
            
            if let validMentees = mentees {
                DispatchQueue.main.async {
                    self.menteeList = self.createMentorMenteeList(validMentees, type: "mentee_id")
                }
            }
        }
        
        JSONConverter.getJSONResponse("mentorships/mentor") { (mentors, error) in
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
                let subject = each["skill_name"] as? String,
                let status = each["status"] as? String,
                let profilePic = each["profile_picture"] as? String {
                
                if type == "mentor_id" {
                    if status == "awaiting_acceptance" {
                        constructedMessage = "awaiting response for" + subject + "help"
                    } else if status == "accepted" {
                        constructedMessage = "is now your \(subject) mentor"
                    } else {
                        constructedMessage = "is too busy to help right now..."
                    }
                }
                
                if type == "mentee_id" {
                    if status == "awaiting_acceptance" {
                        constructedMessage = "is requesting \(subject) help."
                    } else if status == "accepted" {
                        constructedMessage = "is now your \(subject) mentee"
                    } else {
                        constructedMessage = "you are too busy to help right now..."
                    }
                }
                
                let mentorship = Mentorship(aUserID: mentorID, aMenteeFirst: firstName, aMenteeLast: lastName, aStatus: status, aSubject: profilePic, aMessage: constructedMessage)
                
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseTableViewCell") as? ResponseTableViewCell else {return UITableViewCell()}
            
            cell.nameLabel.text = mentorMentee.menteeFullName
            cell.messageLabel.text = mentorMentee.message
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: mentorMentee.subject)
            
            return cell
   
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell") as? InviteTableViewCell else {return UITableViewCell()}
        
        cell.requestLabel.text = mentorMentee.message
        cell.nameLabel.text = mentorMentee.menteeFullName
        cell.delegate = self
        cell.mentorship = mentorMentee
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: mentorMentee.subject)
        
        
        return cell
        
    }
    
    func respondToRequest(_ mentorship: Mentorship, response: String) {
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        let menteeID = mentorship.userID
        
        let responseJSON : [String:Any]
        responseJSON = ["mentee_id" : menteeID, "status" : response, "mentor_message" : ""]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: responseJSON, options: []) {
            
            let url = URL(string: "http://192.168.1.114:3000/api/v1/mentorships/accept_mentee?private_token=\(validToken)")
            var urlRequest = URLRequest(url: url!)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = jsonData
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let validError = error as NSError? {
                    print(validError.localizedDescription)
                    return
                }
                
            }
            
            dataTask.resume()
        }
    }
    
    
    
    
    
}

extension NotifiactionViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BrowseTutorVC") as? BrowseTutorVC else {return}
        
        //vc.skill = skills[indexPath.row]
        //vc.viewType = .specificSkill
        
        //navigationController?.pushViewController(vc, animated: true)
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

extension NotifiactionViewController : InviteViewCellDelegate {
    
    func sendAcceptToAPI(_ mentorship: Mentorship) {
        respondToRequest(mentorship, response: "accepted")
        JSONConverter.getJSONResponse("mentorships/mentee") { (mentees, error) in
            if let err = error {
                print(error?.localizedDescription)
            }
            
            if let validMentees = mentees {
                DispatchQueue.main.async {
                    self.activeArray = self.createMentorMenteeList(validMentees, type: "mentee_id")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func sendRejectToAPI(_ mentorship: Mentorship) {
        respondToRequest(mentorship, response: "refused")
        //fetchMentorships()
        
        JSONConverter.getJSONResponse("mentorships/mentee") { (mentees, error) in
            if let err = error {
                print(error?.localizedDescription)
            }
            
            if let validMentees = mentees {
                DispatchQueue.main.async {
                    self.activeArray = self.createMentorMenteeList(validMentees, type: "mentee_id")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
}
