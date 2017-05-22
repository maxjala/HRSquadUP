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

    @IBOutlet weak var tableView: UITableView!

    var client = ActionCableClient(url: URL(string: "ws://192.168.1.114:3000/cable")!)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //fetchProjectChats

    func mentorInvitesSegmentTapped() {
        //activeArray = userCategories
        //collectionView.reloadData()
    }
    
    func projectInvitesSegmentTapped() {
        //activeArray = projects
        //collectionView.reloadData()
    }
    
    func projectChatsSegmentTapped() {
        //activeArray = projects
        //collectionView.reloadData()
    }
    
    
    
}

extension ChatViewController {
    func setUpActionCableConnection() {
        client.connect()
        
        let room_identifier = ["project_id" : project?.projectId]
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
            
            for person in self.projectMembers! {
                if person.employeeID == senderID {
                    //self.messages.append(JSQMessage(senderId: "\(senderID)", displayName: person.firstName, text: message))
                }
            }
            let lastIndex = IndexPath(item: self.messages.count - 1, section: 0)
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
